From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH 2/2] of: of_mdio: export symbol of_mdiobus_link_phydev
Date: Mon,  2 Jun 2014 13:32:46 +0200
Message-ID: <1401708766-5530-2-git-send-email-zonque@gmail.com>
References: <1401708766-5530-1-git-send-email-zonque@gmail.com>
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	Daniel Mack <zonque@gmail.com>
To: linux-next@vger.kernel.org, davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1401708766-5530-1-git-send-email-zonque@gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make of_mdiobus_link_phydev externally available.
This fixes CONFIG_OF_MDIO=m.

Signed-off-by: Daniel Mack <zonque@gmail.com>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Fixes: 86f6cf41272 ("net: of_mdio: add of_mdiobus_link_phydev()")
---
 drivers/of/of_mdio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index cb36018..b64c258 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -240,6 +240,7 @@ void of_mdiobus_link_phydev(struct mii_bus *mdio,
 		}
 	}
 }
+EXPORT_SYMBOL(of_mdiobus_link_phydev);
 
 /* Helper function for of_phy_find_device */
 static int of_phy_match(struct device *dev, void *phy_np)
-- 
1.9.0
