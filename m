From: Veena Parat <Veena.Parat@neterion.com>
Subject: [PATCH 2.6.22 4/4]S2IO: Implementing review comments from old patches
Date: Mon, 23 Jul 2007 02:39:43 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10707230237190.2793-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:55959 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756026AbXGWGjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 02:39:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Incorporated Jeff Garzik's comments on coding standards

Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN patch_3/drivers/net/s2io.c patch_4/drivers/net/s2io.c
--- patch_3/drivers/net/s2io.c	2007-07-19 17:44:54.000000000 +0530
+++ patch_4/drivers/net/s2io.c	2007-07-19 17:45:41.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.23.1"
+#define DRV_VERSION "2.0.24.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -4818,15 +4818,15 @@ static void s2io_ethtool_gringparam(stru
 		ering->rx_max_pending = MAX_RX_DESC_2;
 
 	ering->tx_max_pending = MAX_TX_DESC;
-	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) {
+	for (i = 0 ; i < sp->config.tx_fifo_num ; i++) 
 		tx_desc_count += sp->config.tx_cfg[i].fifo_len;
-	}
+	
 	DBG_PRINT(INFO_DBG,"\nmax txds : %d\n",sp->config.max_txds);
 	ering->tx_pending = tx_desc_count;
 	rx_desc_count = 0;
-	for (i = 0 ; i < sp->config.rx_ring_num ; i++) {
+	for (i = 0 ; i < sp->config.rx_ring_num ; i++) 
 		rx_desc_count += sp->config.rx_cfg[i].num_rxd;
-	}
+
 	ering->rx_pending = rx_desc_count;
 
 	ering->rx_mini_max_pending = 0;

