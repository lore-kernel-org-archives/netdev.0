From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: hamradio/yam: remove deprecated IRQF_DISABLED
Date: Sat,  5 Oct 2013 06:25:46 +0200
Message-ID: <1380947146-3541-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: jpr@f6fbb.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the use of the IRQF_DISABLED flag

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/hamradio/yam.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 0721e72..ff31ff0 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -888,7 +888,7 @@ static int yam_open(struct net_device *dev)
 		goto out_release_base;
 	}
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, yam_interrupt, IRQF_DISABLED | IRQF_SHARED, dev->name, dev)) {
+	if (request_irq(dev->irq, yam_interrupt, IRQF_SHARED, dev->name, dev)) {
 		printk(KERN_ERR "%s: irq %d busy\n", dev->name, dev->irq);
 		ret = -EBUSY;
 		goto out_release_base;
-- 
1.8.1.2

