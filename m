From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 5/5] ixgb: Driver version, white space,
 comments, device id & other
Date: Tue, 15 Feb 2005 13:39:05 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151202470.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

5 Driver version number, white space, comments, device id & other changes
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.c	2005-02-06 23:33:00.650031648 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.c	2005-02-06 23:33:01.466907464 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ee.h	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ee.h	2005-02-06 23:33:01.482905032 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2005-02-06 23:33:01.503901840 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -63,6 +63,7 @@ static struct ixgb_stats ixgb_gstrings_s
 	{"tx_dropped", IXGB_STAT(net_stats.tx_dropped)},
 	{"multicast", IXGB_STAT(net_stats.multicast)},
 	{"collisions", IXGB_STAT(net_stats.collisions)},
+
 /*	{ "rx_length_errors", IXGB_STAT(net_stats.rx_length_errors) },	*/
 	{"rx_over_errors", IXGB_STAT(net_stats.rx_over_errors)},
 	{"rx_crc_errors", IXGB_STAT(net_stats.rx_crc_errors)},
@@ -98,6 +99,7 @@ static int
 ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
+
 	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	ecmd->port = PORT_FIBRE;
@@ -119,6 +125,7 @@ static int
 ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct ixgb_adapter *adapter = netdev->priv;
+
 	if(ecmd->autoneg == AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb.h net-drivers-2.6/drivers/net/ixgb.new/ixgb.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb.h	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb.h	2005-02-06 23:33:01.521899104 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_hw.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_hw.c	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.c	2005-02-06 23:33:01.546895304 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_hw.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_hw.h	2005-02-06 23:33:00.651031496 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_hw.h	2005-02-06 23:33:01.570891656 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ids.h	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ids.h	2005-02-06 23:33:01.586889224 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-02-06 23:33:01.617884512 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -29,6 +29,9 @@
 #include "ixgb.h"
 
 /* Change Log
+ * 1.0.88 01/05/05
+ * - include fix to the condition that determines when to quit NAPI - Robert Olsson
+ * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
  * 1.0.84 10/26/04
  * - reset buffer_info->dma in Tx resource cleanup logic
  * 1.0.83 10/12/04
@@ -38,13 +41,14 @@
 
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
+
 #ifndef CONFIG_IXGB_NAPI
 #define DRIVERNAPI
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char ixgb_driver_version[] = "1.0.87-k2"DRIVERNAPI;
-char ixgb_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
+char ixgb_driver_version[] = "1.0.90-k2"DRIVERNAPI;
+char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -715,14 +719,8 @@ ixgb_configure_tx(struct ixgb_adapter *a
 	IXGB_WRITE_REG(hw, TDH, 0);
 	IXGB_WRITE_REG(hw, TDT, 0);
 
-	/* don't set up txdctl, it induces performance problems if
-	 * configured incorrectly
-	 txdctl  = TXDCTL_PTHRESH_DEFAULT; // prefetch txds below this threshold
-	 txdctl |= (TXDCTL_HTHRESH_DEFAULT // only prefetch if there are this many ready
-	 << IXGB_TXDCTL_HTHRESH_SHIFT);
-	 IXGB_WRITE_REG (hw, TXDCTL, txdctl);
-	 */
-
+	/* don't set up txdctl, it induces performance problems if configured
+	 * incorrectly */
 	/* Set the Tx Interrupt Delay register */
 
 	IXGB_WRITE_REG(hw, TIDV, adapter->tx_int_delay);
@@ -855,10 +853,17 @@ ixgb_configure_rx(struct ixgb_adapter *a
 	IXGB_WRITE_REG(hw, RDH, 0);
 	IXGB_WRITE_REG(hw, RDT, 0);
 
-						/* burst 16 or burst when RXT0*/
-	rxdctl =  RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT 
-			| RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT 
-			| RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
+	/* set up pre-fetching of receive buffers so we get some before we
+	 * run out (default hardware behavior is to run out before fetching
+	 * more).  This sets up to fetch if HTHRESH rx descriptors are avail
+	 * and the descriptors in hw cache are below PTHRESH.  This avoids
+	 * the hardware behavior of fetching <=512 descriptors in a single
+	 * burst that pre-empts all other activity, usually causing fifo
+	 * overflows. */
+	/* use WTHRESH to burst write 16 descriptors or burst when RXT0 */
+	rxdctl = RXDCTL_WTHRESH_DEFAULT << IXGB_RXDCTL_WTHRESH_SHIFT |
+	         RXDCTL_HTHRESH_DEFAULT << IXGB_RXDCTL_HTHRESH_SHIFT |
+	         RXDCTL_PTHRESH_DEFAULT << IXGB_RXDCTL_PTHRESH_SHIFT;
 	IXGB_WRITE_REG(hw, RXDCTL, rxdctl);
 
 	/* Enable Receive Checksum Offload for TCP and UDP */
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_osdep.h net-drivers-2.6/drivers/net/ixgb.new/ixgb_osdep.h
--- net-drivers-2.6/drivers/net/ixgb/ixgb_osdep.h	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_osdep.h	2005-02-06 23:33:01.634881928 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_param.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_param.c	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_param.c	2005-02-06 23:33:01.653879040 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
	
