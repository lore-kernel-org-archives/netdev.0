From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] ucc_geth: Add SUPPORTED_MII and SUPPORTED_Autoneg
Date: Thu, 4 Aug 2011 15:19:45 +0200
Message-ID: <1312463985-2230-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, Anton Vorontsov <cbouatmailru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:35975 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753635Ab1HDNUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 09:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver supports Autoneg and at least MII. Tell the PHY
that to avoid any confusion in the PHY code.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 06a5db3..fa00935 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1760,10 +1760,12 @@ static int init_phy(struct net_device *dev)
 	if (priv->phy_interface == PHY_INTERFACE_MODE_SGMII)
 		uec_configure_serdes(dev);
 
-	phydev->supported &= (ADVERTISED_10baseT_Half |
-				 ADVERTISED_10baseT_Full |
-				 ADVERTISED_100baseT_Half |
-				 ADVERTISED_100baseT_Full);
+	phydev->supported &= (SUPPORTED_MII |
+			      SUPPORTED_Autoneg |
+			      ADVERTISED_10baseT_Half |
+			      ADVERTISED_10baseT_Full |
+			      ADVERTISED_100baseT_Half |
+			      ADVERTISED_100baseT_Full);
 
 	if (priv->max_speed == SPEED_1000)
 		phydev->supported |= ADVERTISED_1000baseT_Full;
-- 
1.7.3.4

