From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 11/16 2.5] ixgb: explicitly include workqueue.h
Date: Fri, 15 Oct 2004 06:55:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150637060.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2004-10-05 16:03:24.000000000 -0700
@@ -64,6 +64,7 @@
 #ifdef NETIF_F_TSO
 #include <net/checksum.h>
 #endif
+#include <linux/workqueue.h>
 
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
