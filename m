From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: ti: cpmac.c:  Cleaning up missing null-terminate after strncpy call
Date: Sun, 10 Aug 2014 01:41:47 +0200
Message-ID: <1407627707-24303-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added a guaranteed null-terminate after call to strncpy.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/ti/cpmac.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 7399a52..ad268a3 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1125,6 +1125,7 @@ static int cpmac_probe(struct platform_device *pdev)
 		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	}
+	mdio_bus_id[sizeof(mdio_bus_id) - 1] = '\0';
 
 	dev = alloc_etherdev_mq(sizeof(*priv), CPMAC_QUEUES);
 	if (!dev)
-- 
1.7.10.4
