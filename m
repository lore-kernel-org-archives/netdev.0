From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 1/2] net: freescale: ucc_geth: Fix build error from phy_device API change
Date: Tue, 12 Jan 2016 03:24:30 +0100
Message-ID: <1452565471-8953-2-git-send-email-andrew@lunn.ch>
References: <1452565471-8953-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46026 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758927AbcALCYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 21:24:39 -0500
In-Reply-To: <1452565471-8953-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev has moved inside the new mdio structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 0e7f24ec3239..cbddbe2d0429 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -1716,7 +1716,7 @@ static void uec_configure_serdes(struct net_device *dev)
 
 	phy_write(tbiphy, ENET_TBI_MII_CR, TBICR_SETTINGS);
 
-	put_device(&tbiphy->dev);
+	put_device(&tbiphy->mdio.dev);
 }
 
 /* Configure the PHY for dev.
-- 
2.7.0.rc3
