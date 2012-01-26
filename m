From: Stefan Roese <sr@denx.de>
Subject: [PATCH] stmmac: Use correct MDIO bus name so that phy_connect() works again
Date: Thu, 26 Jan 2012 15:46:50 +0100
Message-ID: <1327589210-4424-1-git-send-email-sr@denx.de>
Cc: Florian Fainelli <florian@openwrt.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:23943 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab2AZOrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 09:47:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch db8857bf [stmmac: use an unique MDIO bus name.] changed the
MDIO bus name. After this phy_connect() fails. This patch changes
the bus name in stmmac_mdio.c so that the name matching works
again.

Signed-off-by: Stefan Roese <sr@denx.de>
Cc: Florian Fainelli <florian@openwrt.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index da4a104..7319532 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -154,7 +154,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	else
 		irqlist = priv->mii_irq;
 
-	new_bus->name = "STMMAC MII Bus";
+	new_bus->name = "stmmac";
 	new_bus->read = &stmmac_mdio_read;
 	new_bus->write = &stmmac_mdio_write;
 	new_bus->reset = &stmmac_mdio_reset;
-- 
1.7.8.4
