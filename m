From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.24 3/3]S2io: Updating transceiver information in ethtool
 function
Date: Wed, 22 Aug 2007 03:47:11 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10708220345360.29101-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:46782 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbXHVHrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 03:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Update transceiver information in ethtool function
 
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-08-18 07:19:21.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-08-18 07:20:27.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.4"
+#define DRV_VERSION "2.0.26.5"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -5459,7 +5459,9 @@ static int s2io_ethtool_gset(struct net_
 	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->port = PORT_FIBRE;
-	/* info->transceiver?? TODO */
+
+	/* info->transceiver */
+	info->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(sp->dev)) {
 		info->speed = 10000;

