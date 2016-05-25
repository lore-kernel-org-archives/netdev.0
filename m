From: Marek Vasut <marex@denx.de>
Subject: [PATCH] net: arc: trivial: Replace comma with a semicolon
Date: Thu, 26 May 2016 00:40:05 +0200
Message-ID: <1464216005-6327-1-git-send-email-marex@denx.de>
Cc: Marek Vasut <marex@denx.de>,
	"David S . Miller" <davem@davemloft.net>,
	Caesar Wang <wxt@rock-chips.com>,
	Heiko Stuebner <heiko@sntech.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:44229 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbcEYWkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 18:40:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a typo in the driver, replace comma with a semicolon at the end
of statement. While using comma is a legal C here and probably does
not even generate compiler warning, it was unlikely the intention.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Caesar Wang <wxt@rock-chips.com>
Cc: Heiko Stuebner <heiko@sntech.de>
---
 drivers/net/ethernet/arc/emac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index 16419f5..058460b 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -141,7 +141,7 @@ int arc_mdio_probe(struct arc_emac_priv *priv)
 	priv->bus = bus;
 	bus->priv = priv;
 	bus->parent = priv->dev;
-	bus->name = "Synopsys MII Bus",
+	bus->name = "Synopsys MII Bus";
 	bus->read = &arc_mdio_read;
 	bus->write = &arc_mdio_write;
 	bus->reset = &arc_mdio_reset;
-- 
2.7.0
