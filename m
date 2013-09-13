From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: natsemi: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 06:16:53 +0200
Message-ID: <1379045813-6762-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
code in drivers/net/ethernet/natsemi/

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/natsemi/jazzsonic.c | 3 +--
 drivers/net/ethernet/natsemi/xtsonic.c   | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/jazzsonic.c b/drivers/net/ethernet/natsemi/jazzsonic.c
index c20766c..79257f7 100644
--- a/drivers/net/ethernet/natsemi/jazzsonic.c
+++ b/drivers/net/ethernet/natsemi/jazzsonic.c
@@ -83,8 +83,7 @@ static int jazzsonic_open(struct net_device* dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 				dev->name, dev->irq);
diff --git a/drivers/net/ethernet/natsemi/xtsonic.c b/drivers/net/ethernet/natsemi/xtsonic.c
index c2e0256..4da172a 100644
--- a/drivers/net/ethernet/natsemi/xtsonic.c
+++ b/drivers/net/ethernet/natsemi/xtsonic.c
@@ -95,8 +95,7 @@ static int xtsonic_open(struct net_device *dev)
 {
 	int retval;
 
-	retval = request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED,
-				"sonic", dev);
+	retval = request_irq(dev->irq, sonic_interrupt, 0, "sonic", dev);
 	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 		       dev->name, dev->irq);
-- 
1.8.1.2
