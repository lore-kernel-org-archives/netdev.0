From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 19/21] phy/fixed: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:25 +0100
Message-ID: <1326189567-21663-20-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59921 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031Ab2AJKBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:01:23 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/phy/fixed.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
index 1fa4d73..633680d 100644
--- a/drivers/net/phy/fixed.c
+++ b/drivers/net/phy/fixed.c
@@ -220,7 +220,7 @@ static int __init fixed_mdio_bus_init(void)
 		goto err_mdiobus_reg;
 	}
 
-	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "0");
+	snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "fixed-0");
 	fmb->mii_bus->name = "Fixed MDIO Bus";
 	fmb->mii_bus->priv = fmb;
 	fmb->mii_bus->parent = &pdev->dev;
-- 
1.7.5.4
