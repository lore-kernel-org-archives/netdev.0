From: "Hare, Matthew" <matthew.hare@amsjv.com>
Subject: TCP/IP Window Size Problem/Query
Date: Mon, 11 Aug 2003 17:22:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E28BEE03F7CD3118E540008C7F35FF602C7AFAB@NMEX01>
Mime-Version: 1.0
Content-Type: text/plain;	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'davem@redhat.com'" <davem@redhat.com>, "'ak@muc.de'" <ak@muc.de>,
   "'kuznet@ms2.inr.ac.ru'" <kuznet@ms2.inr.ac.ru>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Forgive this mass mailing out but I am getting desperate for help. My
problem is with reported TCP window sizes.

I have two systems running SuSE Linux. System 1 is running SuSE 7.1 with the
2.2.18 kernel. System 2 is running SuSE 7.3 with the 2.4.17 kernel. Both
systems are PC based (Pentium III, 512MB RAM).

When I open a TCP connection from System 1 I get a reported window size (I
use Ethereal to check window sizes) of 32k. When I do the same with System 2
I get a reported window size of 5840bytes and the window size increases as
the rate of data being sent via TCP increases. This is causing me problems,
I need a fixed window size of 32k on System 2 so that it matches System 1.

I have done a bit of testing to try and work out where this window size is
set. I am by no means a Linux guru so I was working with little knowledge at
the start. The application we use to open the TCP connections is our own
code (C++) so I have hacked that and used some setsockopt() calls to set
SO_SNDBUF. I tried setting this to 32k but this appears to have no effect on
my reported window sizes.

Does anyone know if setsockopt() can be used to change the size of the
window I am seeing? Is SO_SNDBUF the same as the TCP window size that
Ethereal is reporting?

Is there a way to fix the TCP window size in the 2.4.17 kernel? I am
familiar with recompiling the kernel but I've not found any kernel options
that seem to do what I want. Can anyone help me or at least point me in the
right direction?

Thanks for your time.

Mat Hare
SAINTT Developer
AMS UK






********************************************************************
This email and any attachments are confidential to the intended
recipient and may also be privileged. If you are not the intended
recipient please delete it from your system and notify the sender.
You should not copy it or use it for any purpose nor disclose or
distribute its contents to any other person.
********************************************************************
