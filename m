From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: [PATCH] macb: Use semicolon instead of comma for statement
Date: Sat, 12 Apr 2008 00:58:14 +0900 (JST)
Message-ID: <20080412.005814.26099357.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:63866 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113AbYDKP5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 11:57:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems no good reason to use comma here.

Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
---
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d210ed..0881690 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -242,12 +242,12 @@ static int macb_mii_init(struct macb *bp)
 	/* Enable managment port */
 	macb_writel(bp, NCR, MACB_BIT(MPE));
 
-	bp->mii_bus.name = "MACB_mii_bus",
-	bp->mii_bus.read = &macb_mdio_read,
-	bp->mii_bus.write = &macb_mdio_write,
-	bp->mii_bus.reset = &macb_mdio_reset,
-	bp->mii_bus.id = bp->pdev->id,
-	bp->mii_bus.priv = bp,
+	bp->mii_bus.name = "MACB_mii_bus";
+	bp->mii_bus.read = &macb_mdio_read;
+	bp->mii_bus.write = &macb_mdio_write;
+	bp->mii_bus.reset = &macb_mdio_reset;
+	bp->mii_bus.id = bp->pdev->id;
+	bp->mii_bus.priv = bp;
 	bp->mii_bus.dev = &bp->dev->dev;
 	pdata = bp->pdev->dev.platform_data;
 


