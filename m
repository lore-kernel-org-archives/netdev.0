From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] atm: solos-pci: Delete an error message for a failed memory
 allocation in fpga_probe()
Date: Sun, 6 Aug 2017 10:41:47 +0200
Message-ID: <997c2270-135d-0ac9-e6f0-f62cf0750a79@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 6 Aug 2017 10:37:31 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/atm/solos-pci.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 8754793223cd..cb3424a4f91f 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1293,7 +1293,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 			card->dma_alignment = 3;
 			card->dma_bounce = kmalloc(card->nr_ports * BUF_SIZE, GFP_KERNEL);
 			if (!card->dma_bounce) {
-				dev_warn(&card->dev->dev, "Failed to allocate DMA bounce buffers\n");
 				err = -ENOMEM;
 				/* Fallback to MMIO doesn't work */
 				goto out_unmap_both;
-- 
2.13.4
