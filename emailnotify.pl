#!perl

#
# emailnotify.pl - a CGI script which exemplifies e-mail notification.
# neue Version
# noch neuere Version 24.9.21 / 11:57
#

use CGI::Form;
use Mail::Send;

$q = new CGI::Form;
$DATABASEFILE = "licenseplates.db";

print $q->header();
print $q->header();
print $q->header();
print $q->start_html();
if ($q->cgi->var('REQUEST_METHOD') eq 'GET') {
   &licensePlateForm($q);
} else {
   my($action)=$q->param('Action');
   if ($action eq 'Query') {
      &printInfo($q->param('LicensePlate'));
   } elsif ($action eq 'Notify') {
      &notifyOwner($q->param('LicensePlate'),$q->param('FindersName'));
   }
}
print $q->end_html();

sub licensePlateForm {
   my($q)=@_;
   print "<P>Please enter a license plate number";
   print " and select one of the options.\n";
   print "<P><B>Notify</B> will send e-mail to the owner.\n";
   print "<P><B>Query</B> will display the information about";
   print " this license plate.\n";
   print $q->start_multipart_form();
   print "<P>License plate: ";
   print $q->textfield(-name=>'LicensePlate',-maxlength=>7,-size=>7);
   print "<P>Your name: ";
   print $q->textfield(-name=>'FindersName',-maxlength=>32,-size=>32);
   print "<BR><BR><BR>";
   print $q->submit(-name=>'Action',-value=>'Query');
   print " ";
   print $q->submit(-name=>'Action',-value=>'Notify');
   print " ";
   print $q->reset();
   print $q->endform();
}

sub findLicensePlate {
   my($licensePlate)=@_;
   my(%info);
   if (open(DATABASE, "< $DATABASEFILE")) {
      $srchStr="^(?i)$licensePlate\\<\\*\\>";
      while (<DATABASE>) {
         if (/$srchStr/) {
            ($info{'lic'},$info{'name'},$info{'email'},
             $info{'color'},$info{'make'},$info{'model'})=split('<*>');
            last;
         }
      }
      close(DATABASE);
   }
   return %info;
}

sub printInfo {
   my($licensePlate)=@_;
   my(%info)=&findLicensePlate($licensePlate);
   if (defined($info{'name'})) {
      print "<P><B>Owner</B> is: $info{'name'}<BR>\n";
      print "<P><B>E-mail Address</B> is: $info{'email'}<BR>\n";
      print "<P><B>Color</B> is: $info{'color'}<BR>\n";
      print "<P><B>Make</B> is: $info{'make'}<BR>\n";
      print "<P><B>Model</B> is: $info{'model'}<BR>\n";
   } else {
      print "<P>Sorry, that license plate number was not found";
      print " in our database<BR>\n";
   }
}

sub notifyOwner {
   my($licensePlate,$notifier)=@_;
   my(%info)=&findLicensePlate($licensePlate);
   if (defined($info{'email'})) {
      $msg = new Mail::Send;
      $msg->to($info{'email'});
      $msg->subject("Hey! YouÕre lights are on! ");
      $fh = $msg->open();
      print $fh "$info{'name'},\n   Are you the owner of that ";
      print $fh "$info{'color'} $info{'make'} $info{'model'}?\n";
      print $fh "If so, your lights are on.\n";
      print $fh "Sincerely yours,\n$notifier\n";
      $msg->close();
      print "$info{'name'} has been notified! ";
   } else {
      print "<P>Sorry, that license plate number was not found";
      print " in our database<BR>\n";
   }
}

