From: Matthew Wilcox <willy@debian.org>
Subject: socket(7) error?
Date: Thu, 21 Aug 2003 04:19:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821031938.GA19630@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi.  There's a bug report from Martin Pool against manpages-dev suggesting
the following paragraph from socket(7) is incorrect:

       SO_RCVTIMEO and SO_SNDTIMEO
              Specify  the  sending  or  receiving timeouts until reporting an
              error.  They are fixed to a protocol specific setting  in  Linux
              and  cannot  be read or written. Their functionality can be emu-
              lated using alarm(2) or setitimer(2).

He says:

   In fact, these options do seem to be at least partially implemented
   in Linux 2.4.20.  You can at least set and retrieve a value against
   a socket, and it does seem to affect the (complex) network scheduling
   code.

   I have not actually tested that they work as advertised, so it might
   be good to check with somebody who knows more about it.  But the
   manpage does seem to be at least partially wrong.

This is me checking with people who know more about it ;-)  Let me know
what to say and I'll send a patch to Andries.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
