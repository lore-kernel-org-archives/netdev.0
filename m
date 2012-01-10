From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 13/21] smsc911x: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:19 +0100
Message-ID: <1326189567-21663-14-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59802 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755999Ab2AJKAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:49 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 9d0b8ce..24d2df0 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1044,7 +1044,8 @@ static int __devinit smsc911x_mii_init(struct platform_device *pdev,
 	}
 
 	pdata->mii_bus->name = SMSC_MDIONAME;
-	snprintf(pdata->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	snprintf(pdata->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, pdev->id);
 	pdata->mii_bus->priv = pdata;
 	pdata->mii_bus->read = smsc911x_mii_read;
 	pdata->mii_bus->write = smsc911x_mii_write;
-- 
1.7.5.4
