From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/ipv6/ndisc.c: make a function static
Date: Tue, 15 Mar 2005 15:47:13 +0100
Message-ID: <20050315144712.GM3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global function static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-mm3-full/net/ipv6/ndisc.c.old	2005-03-15 13:33:29.000000000 +0100
+++ linux-2.6.11-mm3-full/net/ipv6/ndisc.c	2005-03-15 13:34:03.000000000 +0100
@@ -1594,10 +1594,11 @@
 	return ret;
 }
 
-int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name, int nlen,
-				 void __user *oldval, size_t __user *oldlenp,
-				 void __user *newval, size_t newlen,
-				 void **context)
+static int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
+					int nlen, void __user *oldval,
+					size_t __user *oldlenp,
+					void __user *newval, size_t newlen,
+					void **context)
 {
 	struct net_device *dev = ctl->extra1;
 	struct inet6_dev *idev;
