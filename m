From: domen@coderock.org
Subject: [patch 2/3] drivers/net/wireless/prism54/islpci_hotplug: Use the DMA_{64, 32}BIT_MASK constants
Date: Sun, 06 Mar 2005 23:23:55 +0100
Message-ID: <20050306222355.6686C1ED3D@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, tklauser@nuerscht.ch
To: prism54-private@prism54.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()

Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_wireless_prism54_islpci_hotplug drivers/net/wireless/prism54/islpci_hotplug.c
--- kj/drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_wireless_prism54_islpci_hotplug	2005-03-05 16:12:02.000000000 +0100
+++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05 16:12:02.000000000 +0100
@@ -125,7 +125,7 @@ prism54_probe(struct pci_dev *pdev, cons
 	}
 
 	/* enable PCI DMA */
-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
 		printk(KERN_ERR "%s: 32-bit PCI DMA not supported", DRV_NAME);
 		goto do_pci_disable_device;
         }
_
