From: Jason <bofh1234567@yahoo.com>
Subject: SO_REUSEPORT and multicasting
Date: Thu, 15 Jun 2006 06:31:32 -0700 (PDT)
Message-ID: <20060615133132.43716.qmail@web53608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53608.mail.yahoo.com ([206.190.37.41]:63346 "HELO
	web53608.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1030403AbWFONbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 09:31:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I wrote a program that uses multicasting to send data.
 It works great on HP-UX but does not work on Fedora
Core 5.  I emailed the fedora list but they were of
little to no help.  

Does the kernel support SO_REUSEPORT?  If so can
anyone give me some suggestions why my program does
not work on Linux?  I did a route add -net 224.0.0.0/4
dev eth0 but that did not do anything.

I have found out since I posted this message to
linux-kernel that SO_REUSEPORT is a BSDism.  The Linux
equivalent is SO_REUSEADDR which I did try.  My
program compiles cleanly using SO_REUSEADDR, but the
server does not receive any messages.  

I am trying to run the client and server on the same
PC.  This is just for faster development.  I can code
faster on my home Linux system than I can on the
remote HP-UX system.

Thanks,

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam
protection around 
http://mail.yahoo.com 

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
