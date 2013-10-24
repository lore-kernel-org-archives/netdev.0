From: "Luke C. Jones" <luke.christopher.jones@gmail.com>
Subject: [PATCH net-next] ns83820: printk() cleanup
Date: Thu, 24 Oct 2013 21:45:06 +0000
Message-ID: <1382651106-24550-1-git-send-email-Luke.Christopher.Jones@gmail.com>
Cc: "Luke C. Jones" <jonesl4@rpi.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f54.google.com ([209.85.128.54]:37393 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359Ab3JXVpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 17:45:14 -0400
Received: by mail-qe0-f54.google.com with SMTP id 1so1874718qec.27
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 14:45:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luke C. Jones" <jonesl4@rpi.edu>

In an effort to bring all printk calls up to style standards,
added log levels to printk calls.

Reviewed-by: Mike Mathis <mathim2@rpi.edu>
Reviewed-by: Jonathan Beekman <beekmj@rpi.edu>
Signed-off-by: Luke C. Jones <jonesl4@rpi.edu>
---
 drivers/net/ethernet/natsemi/ns83820.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index d3b4700..d7f849d 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -1580,7 +1580,7 @@ static void ns83820_tx_timeout(struct net_device *ndev)
 	{
 		u32 isr;
 		isr = readl(dev->base + ISR);
-		printk("irq: %08x imr: %08x\n", isr, dev->IMR_cache);
+		printk(KERN_DEBUG "irq: %08x imr: %08x\n", isr, dev->IMR_cache);
 		ns83820_do_isr(ndev, isr);
 	}
 #endif
@@ -1603,7 +1603,7 @@ static void ns83820_tx_watch(unsigned long data)
 	struct ns83820 *dev = PRIV(ndev);
 
 #if defined(DEBUG)
-	printk("ns83820_tx_watch: %u %u %d\n",
+	printk(KERN_DEBUG "ns83820_tx_watch: %u %u %d\n",
 		dev->tx_done_idx, dev->tx_free_idx, atomic_read(&dev->nr_tx_skbs)
 		);
 #endif
@@ -2026,7 +2026,7 @@ static int ns83820_init_one(struct pci_dev *pci_dev,
 		goto out_free_irq;
 	}
 
-	printk("%s: ns83820.c: 0x22c: %08x, subsystem: %04x:%04x\n",
+	printk(KERN_INFO "%s: ns83820.c: 0x22c: %08x, subsystem: %04x:%04x\n",
 		ndev->name, le32_to_cpu(readl(dev->base + 0x22c)),
 		pci_dev->subsystem_vendor, pci_dev->subsystem_device);
 
-- 
1.8.1.2
