From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcm63xx_enet: Fix build failure with phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 18:21:09 -0800
Message-ID: <20161116022109.26935-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35244 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932170AbcKPCVM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 21:21:12 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so13286409pga.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 18:21:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced a typo making the driver no longer build, *sigh*.

Fixes: 42469bf5d9bb ("net: bcm63xx_enet: Utilize phy_ethtool_nway_reset")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a43ab90c051e..3b14d5144228 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1435,7 +1435,7 @@ static int bcm_enet_nway_reset(struct net_device *dev)
 
 	priv = netdev_priv(dev);
 	if (priv->has_phy)
-		return phy_ethtool_nway_reset(dev),
+		return phy_ethtool_nway_reset(dev);
 
 	return -EOPNOTSUPP;
 }
-- 
2.9.3
