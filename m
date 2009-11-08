From: Marin Mitov <mitov@issp.bas.bg>
Subject: [PATCH]Use DMA_BIT_MASK(44) instead of deprecated DMA_44BIT_MASK
Date: Sun, 8 Nov 2009 17:59:27 +0200
Message-ID: <200911081759.27263.mitov@issp.bas.bg>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754458AbZKHQAe@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Use DMA_BIT_MASK(44) instead of deprecated DMA_44BIT_MASK

Signed-off-by: Marin Mitov <mitov@issp.bas.bg>

=========================================================
--- a/drivers/net/niu.c	2009-11-08 17:09:40.000000000 +0200
+++ b/drivers/net/niu.c	2009-11-08 17:10:31.000000000 +0200
@@ -45,10 +45,6 @@
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 
-#ifndef DMA_44BIT_MASK
-#define DMA_44BIT_MASK	0x00000fffffffffffULL
-#endif
-
 #ifndef readq
 static u64 readq(void __iomem *reg)
 {
@@ -9915,7 +9911,7 @@
 		  PCI_EXP_DEVCTL_RELAX_EN);
 	pci_write_config_word(pdev, pos + PCI_EXP_DEVCTL, val16);
 
-	dma_mask = DMA_44BIT_MASK;
+	dma_mask = DMA_BIT_MASK(44);
 	err = pci_set_dma_mask(pdev, dma_mask);
 	if (!err) {
 		dev->features |= NETIF_F_HIGHDMA;
