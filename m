From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: pxa168_eth: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:04:23 +0200
Message-ID: <1379045063-6604-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 4ae0c74..fff6246 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1123,8 +1123,7 @@ static int pxa168_eth_open(struct net_device *dev)
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	int err;
 
-	err = request_irq(dev->irq, pxa168_eth_int_handler,
-			  IRQF_DISABLED, dev->name, dev);
+	err = request_irq(dev->irq, pxa168_eth_int_handler, 0, dev->name, dev);
 	if (err) {
 		dev_err(&dev->dev, "can't assign irq\n");
 		return -EAGAIN;
-- 
1.8.1.2
