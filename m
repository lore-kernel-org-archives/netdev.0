From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 18/21] bcm63xx_enet: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:24 +0100
Message-ID: <1326189567-21663-19-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Rick Jones <rick.jones2@hp.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59922 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755135Ab2AJKBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:01:23 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index a11a8ad..0e871b0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1727,7 +1727,7 @@ static int __devinit bcm_enet_probe(struct platform_device *pdev)
 		bus->priv = priv;
 		bus->read = bcm_enet_mdio_read_phylib;
 		bus->write = bcm_enet_mdio_write_phylib;
-		sprintf(bus->id, "%d", priv->mac_id);
+		sprintf(bus->id, "%s-%d", pdev->name, priv->mac_id);
 
 		/* only probe bus where we think the PHY is, because
 		 * the mdio read operation return 0 instead of 0xffff
-- 
1.7.5.4
