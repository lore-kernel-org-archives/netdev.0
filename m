From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/12) skge: spelling and whitespace
Date: Thu, 3 Mar 2005 11:33:29 -0800
Message-ID: <20050303113329.2a0171c3@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix spelling and whitespace issues

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:09:26.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:15:44.000000000 -0800
@@ -1,10 +1,10 @@
 /*
- * New driver for Marvell Yukon chipsent and SysKonnect Gigabit
+ * New driver for Marvell Yukon chipset and SysKonnect Gigabit
  * Ethernet adapters. Based on earlier sk98lin, e100 and
- * Freebsd if_sk drivers.
+ * FreeBSD if_sk drivers.
  *
  * This driver intentionally does not support all the features
- * of the original driver such as link failover and link management because
+ * of the original driver such as link fail-over and link management because
  * those should be done at higher levels.
  *
  * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
@@ -125,8 +125,7 @@
 
 /*
  * Returns copy of control register region
- * I/O region is divided into banks and certain regions
- * are unreadable
+ * I/O region is divided into banks and certain regions are unreadable
  */
 static void skge_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			  void *p)
@@ -338,7 +337,7 @@
 
 	{ "collisions",		XM_TXF_SNG_COL, GM_TXF_SNG_COL },
 	{ "multi_collisions",	XM_TXF_MUL_COL, GM_TXF_MUL_COL },
-	{ "aborted",		XM_TXF_ABO_COL, GM_TXF_ABO_COL},
+	{ "aborted",		XM_TXF_ABO_COL, GM_TXF_ABO_COL },
 	{ "late_collision",	XM_TXF_LAT_COL, GM_TXF_LAT_COL },
 	{ "fifo_underrun",	XM_TXE_FIFO_UR, GM_TXE_FIFO_UR },
 	{ "fifo_overflow",	XM_RXE_FIFO_OV, GM_RXE_FIFO_OV },
