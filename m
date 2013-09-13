From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: hp100: remove deprecated IRQF_DISABLED
Date: Fri, 13 Sep 2013 05:51:24 +0200
Message-ID: <1379044284-6448-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: perex@perex.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/hp/hp100.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/hp/hp100.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index e3c7c69..91227d0 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1097,7 +1097,7 @@ static int hp100_open(struct net_device *dev)
 	/* New: if bus is PCI or EISA, interrupts might be shared interrupts */
 	if (request_irq(dev->irq, hp100_interrupt,
 			lp->bus == HP100_BUS_PCI || lp->bus ==
-			HP100_BUS_EISA ? IRQF_SHARED : IRQF_DISABLED,
+			HP100_BUS_EISA ? IRQF_SHARED : 0,
 			"hp100", dev)) {
 		printk("hp100: %s: unable to get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
-- 
1.8.1.2
