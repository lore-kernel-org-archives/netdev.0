From: akpm@linux-foundation.org
Subject: [patch 8/8] irda: follow lspci device/vendor style
Date: Mon, 22 Sep 2008 14:50:43 -0700
Message-ID: <200809222150.m8MLohVg031878@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	bjorn.helgaas@hp.com, samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38679 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753848AbYIVV5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjorn Helgaas <bjorn.helgaas@hp.com>

Use "[%04x:%04x]" for PCI vendor/device IDs to follow the format used by
lspci(8).

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/vlsi_ir.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/irda/vlsi_ir.c~irda-follow-lspci-device-vendor-style drivers/net/irda/vlsi_ir.c
--- a/drivers/net/irda/vlsi_ir.c~irda-follow-lspci-device-vendor-style
+++ a/drivers/net/irda/vlsi_ir.c
@@ -165,7 +165,7 @@ static void vlsi_proc_pdev(struct seq_fi
 	unsigned iobase = pci_resource_start(pdev, 0);
 	unsigned i;
 
-	seq_printf(seq, "\n%s (vid/did: %04x/%04x)\n",
+	seq_printf(seq, "\n%s (vid/did: [%04x:%04x])\n",
 		   pci_name(pdev), (int)pdev->vendor, (int)pdev->device);
 	seq_printf(seq, "pci-power-state: %u\n", (unsigned) pdev->current_state);
 	seq_printf(seq, "resources: irq=%u / io=0x%04x / dma_mask=0x%016Lx\n",
_
