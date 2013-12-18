From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/9] net: phy: mdio_bus: fix checkpath error
Date: Tue, 17 Dec 2013 21:38:10 -0800
Message-ID: <1387345093-14168-7-git-send-email-f.fainelli@gmail.com>
References: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:56002 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3LRFib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 00:38:31 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so7738720oag.2
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 21:38:30 -0800 (PST)
In-Reply-To: <1387345093-14168-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 5617876..33e1c86 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -316,8 +316,8 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 	if (phydrv->match_phy_device)
 		return phydrv->match_phy_device(phydev);
 
-	return ((phydrv->phy_id & phydrv->phy_id_mask) ==
-		(phydev->phy_id & phydrv->phy_id_mask));
+	return (phydrv->phy_id & phydrv->phy_id_mask) ==
+		(phydev->phy_id & phydrv->phy_id_mask);
 }
 
 #ifdef CONFIG_PM
-- 
1.8.3.2
