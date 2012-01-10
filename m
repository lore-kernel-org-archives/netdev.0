From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 12/21] s6gmac: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:18 +0100
Message-ID: <1326189567-21663-13-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59801 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756001Ab2AJKAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:00:50 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/s6gmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index a7ff8ea..22e9c01 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -1004,7 +1004,7 @@ static int __devinit s6gmac_probe(struct platform_device *pdev)
 	mb->write = s6mii_write;
 	mb->reset = s6mii_reset;
 	mb->priv = pd;
-	snprintf(mb->id, MII_BUS_ID_SIZE, "0");
+	snprintf(mb->id, MII_BUS_ID_SIZE, "%s-%x", pdev->name, pdev->id);
 	mb->phy_mask = ~(1 << 0);
 	mb->irq = &pd->mii.irq[0];
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-- 
1.7.5.4
