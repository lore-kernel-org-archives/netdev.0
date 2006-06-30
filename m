From: akpm@osdl.org
Subject: [patch 2/5] forcedeth: typecast cleanup
Date: Fri, 30 Jun 2006 02:25:04 -0700
Message-ID: <200606300925.k5U9P4Cn001386@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, aabdulla@nvidia.com,
	manfred@colorfullife.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55951 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751665AbWF3JZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:25:30 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

Someone went nuts in there.

Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: Manfred Spraul <manfred@colorfullife.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/forcedeth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-typecast-cleanup drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-typecast-cleanup
+++ a/drivers/net/forcedeth.c
@@ -2761,22 +2761,22 @@ static void nv_do_nic_poll(unsigned long
 	pci_push(base);
 
 	if (!using_multi_irqs(dev)) {
-		nv_nic_irq((int) 0, (void *) data, (struct pt_regs *) NULL);
+		nv_nic_irq(0, dev, NULL);
 		if (np->msi_flags & NV_MSI_X_ENABLED)
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
 		else
 			enable_irq(dev->irq);
 	} else {
 		if (np->nic_poll_irq & NVREG_IRQ_RX_ALL) {
-			nv_nic_irq_rx((int) 0, (void *) data, (struct pt_regs *) NULL);
+			nv_nic_irq_rx(0, dev, NULL);
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_TX_ALL) {
-			nv_nic_irq_tx((int) 0, (void *) data, (struct pt_regs *) NULL);
+			nv_nic_irq_tx(0, dev, NULL);
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector);
 		}
 		if (np->nic_poll_irq & NVREG_IRQ_OTHER) {
-			nv_nic_irq_other((int) 0, (void *) data, (struct pt_regs *) NULL);
+			nv_nic_irq_other(0, dev, NULL);
 			enable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector);
 		}
 	}
_
