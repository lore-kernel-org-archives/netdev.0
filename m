From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.22 3/3]S2io: Increment received packet count correctly
Date: 25 Jul 2007 19:43:12 -0700
Message-ID: <1185417791.21141.50.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:56151 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbXGZAsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 20:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Fix to increment the received packet count correctly.

(Resending; Removed HTML sections in the patch)

Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
---
diff -Nurp 2.0.24.1P2/drivers/net/s2io.c 2.0.24.1P3/drivers/net/s2io.c
--- 2.0.24.1P2/drivers/net/s2io.c	2007-07-20 16:26:13.000000000 -0700
+++ 2.0.24.1P3/drivers/net/s2io.c	2007-07-20 16:40:02.000000000 -0700
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.24.1"
+#define DRV_VERSION "2.0.25.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -6734,6 +6734,7 @@ static int rx_osm_handler(struct ring_in
 	}
 
 	/* Updating statistics */
+	sp->stats.rx_packets++;
 	rxdp->Host_Control = 0;
 	if (sp->rxd_mode == RXD_MODE_1) {
 		int len = RXD_GET_BUFFER0_SIZE_1(rxdp->Control_2);



