From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Fw: throttling kernel messages: KERNEL: assertion (flags &
 MSG_PEEK) failed at net/ipv4/tcp.c (1282)
Date: Tue, 12 Apr 2005 11:41:48 -0700
Message-ID: <20050412114148.66283c58.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


FYI.


Begin forwarded message:

Date: Tue, 12 Apr 2005 11:41:48 +0200
From: "Ulrich Windl" <ulrich.windl@rz.uni-regensburg.de>
To: linux-kernel@vger.kernel.org
Subject: throttling kernel messages: KERNEL: assertion (flags & MSG_PEEK) failed at net/ipv4/tcp.c (1282)


Hi,

I'm affected by the (in)famous bug:
Apr 12 07:03:02 mailgate kernel: recvmsg bug: copied D640F0D1 seq D640F679
Apr 12 07:03:02 mailgate kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1282)
Apr 12 07:03:02 mailgate kernel: recvmsg bug: copied D640F0D1 seq D640F679
Apr 12 07:03:02 mailgate kernel: KERNEL: assertion (flags & MSG_PEEK) failed at 
net/ipv4/tcp.c (1282)

(Kernel of SuSE Linux 9.2, 2.6.8-24.13-default #1 Fri Mar 18 10:19:42 UTC 2005 
i686 i686 i386 GNU/Linux)

The kernel spits out hundreds to thousand messages per second, making klogd and 
syslogd quite busy, and my messages file stopped growing at 2GB.

I'd suggest to enable throttling for this message, or trigger a panic/reboot, or 
maybe even fix the bug or message. ;-)

Regards,
Ulrich

-
