From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/2] net: freescale: mac-fec: Fix build error from phy_device API change
Date: Tue, 12 Jan 2016 03:24:31 +0100
Message-ID: <1452565471-8953-3-git-send-email-andrew@lunn.ch>
References: <1452565471-8953-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46030 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758927AbcALCYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 21:24:46 -0500
In-Reply-To: <1452565471-8953-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev has moved inside the new mdio structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/ethernet/freescale/fs_enet/mac-fec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
index c158d409f6af..bade2f8f9b5c 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
@@ -363,7 +363,7 @@ static void stop(struct net_device *dev)
 	const struct fs_platform_info *fpi = fep->fpi;
 	struct fec __iomem *fecp = fep->fec.fecp;
 
-	struct fec_info* feci= fep->phydev->bus->priv;
+	struct fec_info *feci = fep->phydev->mdio.bus->priv;
 
 	int i;
 
-- 
2.7.0.rc3
