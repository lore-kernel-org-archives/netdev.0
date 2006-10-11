From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 05/10] sky2: advertising register 16 bits
Date: Wed, 11 Oct 2006 14:22:30 -0700
Message-ID: <20061011212310.838374422@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54989 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422639AbWJKV11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:27:27 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-advertise-bits.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The advertising bits (from ethtool.h) fit in 16 bits.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.h	2006-10-11 11:56:25.000000000 -0700
+++ sky2/drivers/net/sky2.h	2006-10-11 11:56:42.000000000 -0700
@@ -1860,7 +1860,7 @@
 
 	dma_addr_t	     rx_le_map;
 	dma_addr_t	     tx_le_map;
-	u32		     advertising;	/* ADVERTISED_ bits */
+	u16		     advertising;	/* ADVERTISED_ bits */
 	u16		     speed;	/* SPEED_1000, SPEED_100, ... */
 	u8		     autoneg;	/* AUTONEG_ENABLE, AUTONEG_DISABLE */
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */

--
Stephen Hemminger <shemminger@osdl.org>

