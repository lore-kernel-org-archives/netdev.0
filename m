From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 3/5] arcnet: com20020: remove needless base_addr assignment
Date: Wed, 28 Jun 2017 18:28:35 +0200
Message-ID: <20170628162837.21856-4-m.grzeschik@pengutronix.de>
References: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:43597 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751521AbdF1Q2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 12:28:51 -0400
In-Reply-To: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The assignment is superfluous.

Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 13d9ad4b3f5c9..78043a9c5981e 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -246,8 +246,6 @@ int com20020_found(struct net_device *dev, int shared)
 		return -ENODEV;
 	}
 
-	dev->base_addr = ioaddr;
-
 	arc_printk(D_NORMAL, dev, "%s: station %02Xh found at %03lXh, IRQ %d.\n",
 		   lp->card_name, dev->dev_addr[0], dev->base_addr, dev->irq);
 
-- 
2.11.0
