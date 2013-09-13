From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: pasemi: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:21:24 +0200
Message-ID: <1379046084-6825-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: olof@lixom.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/pasemi/pasemi_mac.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index c498181..5b65356 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1219,7 +1219,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
 		 dev->name);
 
-	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, 0,
 			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -1230,7 +1230,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
 		 dev->name);
 
-	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, 0,
 			  mac->rx_irq_name, mac->rx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
-- 
1.8.1.2
