From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] missing statics in atm
Date: Sat, 14 Aug 2004 16:33:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814143324.GA26061@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.35/net/atm/clip.c	2004-07-13 15:39:15 +02:00
+++ edited/net/atm/clip.c	2004-08-11 12:00:00 +02:00
@@ -47,8 +47,8 @@
 #endif
 
 
-struct net_device *clip_devs = NULL;
-struct atm_vcc *atmarpd = NULL;
+static struct net_device *clip_devs;
+static struct atm_vcc *atmarpd;
 static struct neigh_table clip_tbl;
 static struct timer_list idle_timer;
 static int start_timer = 1;
===== net/atm/ipcommon.h 1.1 vs edited =====
--- 1.1/net/atm/ipcommon.h	2002-02-05 18:40:00 +01:00
+++ edited/net/atm/ipcommon.h	2004-08-11 11:59:21 +02:00
@@ -12,9 +12,6 @@
 #include <linux/netdevice.h>
 #include <linux/atmdev.h>
 
-
-extern struct net_device *clip_devs;
-
 /*
  * Appends all skbs from "from" to "to". The operation is atomic with respect
  * to all other skb operations on "from" or "to".
