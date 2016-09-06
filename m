From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: arc_emac: mark arc_mdio_reset() static
Date: Tue,  6 Sep 2016 16:21:56 +0800
Message-ID: <1473150116-26226-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: davem@davemloft.net, wxt@rock-chips.com, heiko@sntech.de,
        marex@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/arc/emac_mdio.c:107:5: warning: no previous prototype for 'arc_mdio_reset' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/arc/emac_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_mdio.c b/drivers/net/ethernet/arc/emac_mdio.c
index 058460b..a22403c 100644
--- a/drivers/net/ethernet/arc/emac_mdio.c
+++ b/drivers/net/ethernet/arc/emac_mdio.c
@@ -104,7 +104,7 @@ static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
  * @bus: points to the mii_bus structure
  * Description: reset the MII bus
  */
-int arc_mdio_reset(struct mii_bus *bus)
+static int arc_mdio_reset(struct mii_bus *bus)
 {
 	struct arc_emac_priv *priv = bus->priv;
 	struct arc_emac_mdio_bus_data *data = &priv->bus_data;
-- 
2.7.4
