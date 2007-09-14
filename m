From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 3/3]S2io: Updating transceiver information in ethtool
 function
Date: Fri, 14 Sep 2007 07:43:16 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709140741440.474-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:53025 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbXINLnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 07:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Update transceiver information in ethtool function

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-09-06 18:31:27.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-09-06 18:36:05.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.4"
+#define DRV_VERSION "2.0.26.5"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -5124,7 +5124,9 @@ static int s2io_ethtool_gset(struct net_
 	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->port = PORT_FIBRE;
-	/* info->transceiver?? TODO */
+
+	/* info->transceiver */
+	info->transceiver = XCVR_EXTERNAL;
 
 	if (netif_carrier_ok(sp->dev)) {
 		info->speed = 10000;

