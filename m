From: James Chapman <jchapman@katalix.com>
Subject: PPP-over-L2TP kernel support, patch for review
Date: Mon,  6 Sep 2004 12:55:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094471744.413c5040e7f06@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Martijn van Oosterhout <kleptog@svana.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Attached is a PPP-over-L2TP driver for review. The patch is against
vanilla 2.6.8.1. It was originally developed for 2.4 and forward-
ported to 2.6 so please look for typical 2.4-to-2.6 porting bugs. The
original version of this driver was written by Martijn van Oosterhout,
distributed as kl2tp-0.2 last year.

Note that this code handles only the datapath of L2TP; a userland
daemon runs the L2TP control protocol, setting up tunnels and sessions
with its peers. OpenL2TP is a recently released L2TP client/server
written specifically for Linux and includes this driver in its
distribution, http://openl2tp.sourceforge.net.

I'm working towards having this driver integrated into the kernel
tree. Comments?

/jc
