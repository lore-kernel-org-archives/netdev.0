From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 01/21] ax88796: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:07 +0100
Message-ID: <1326189567-21663-2-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59567 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755952Ab2AJJ76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 04:59:58 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/8390/ax88796.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 9e8ba4f..0f92e35 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -623,7 +623,8 @@ static int ax_mii_init(struct net_device *dev)
 
 	ax->mii_bus->name = "ax88796_mii_bus";
 	ax->mii_bus->parent = dev->dev.parent;
-	snprintf(ax->mii_bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
+	snprintf(ax->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		pdev->name, pdev->id);
 
 	ax->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!ax->mii_bus->irq) {
-- 
1.7.5.4
