From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 13/16] net: stmmac: print phy information
Date: Wed,  8 Feb 2017 09:31:18 +0100
Message-ID: <20170208083121.27949-14-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a PHY is found, printing which one was found (and which type/model) is
a good information to know.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index cc88bdb..9805aa8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -870,9 +870,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	if (phydev->is_pseudo_fixed_link)
 		phydev->irq = PHY_POLL;
 
-	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
-		   __func__, phydev->phy_id, phydev->link);
-
+	phy_attached_info(phydev);
 	return 0;
 }
 
-- 
2.10.2
