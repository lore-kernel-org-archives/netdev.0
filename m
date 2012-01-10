From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 15/21] cpmac: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:21 +0100
Message-ID: <1326189567-21663-16-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59860 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321Ab2AJKBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:01:07 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/ti/cpmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index aaac0c7..4d9a28f 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1269,7 +1269,7 @@ int __devinit cpmac_init(void)
 	}
 
 	cpmac_mii->phy_mask = ~(mask | 0x80000000);
-	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "1");
+	snprintf(cpmac_mii->id, MII_BUS_ID_SIZE, "cpmac-1");
 
 	res = mdiobus_register(cpmac_mii);
 	if (res)
-- 
1.7.5.4
