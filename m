From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 01:57:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041003235737.GO14344@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041003161436.50293f9a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20041003161436.50293f9a.davem@davemloft.net> 2004-10-03 16:14
> First, how does this new thing ever get built into the tree?

I misunderstood you before and didn't realize I missed to diff the
Makefile part. Sorry about that.

--- linux-2.6.9-rc3.orig/net/core/Makefile	2004-10-04 01:55:37.000000000 +0200
+++ linux-2.6.9-rc3/net/core/Makefile	2004-09-30 21:30:42.000000000 +0200
@@ -2,7 +2,7 @@
 # Makefile for the Linux networking core.
 #
 
-obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o
+obj-y := sock.o skbuff.o iovec.o datagram.o stream.o scm.o gen_stats.o gen_estimator.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
