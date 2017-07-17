From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 08/11] net: cadence: macb: constify pci_device_id.
Date: Mon, 17 Jul 2017 23:41:52 +0530
Message-ID: <1500315112-3249-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nicolas.ferre@microchip.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
    791	    336	      0	   1127	    467	net/ethernet/cadence/macb_pci.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
    855	    272	      0	   1127	    467	net/ethernet/cadence/macb_pci.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/cadence/macb_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb_pci.c b/drivers/net/ethernet/cadence/macb_pci.c
index 9906fda..248a8fc 100644
--- a/drivers/net/ethernet/cadence/macb_pci.c
+++ b/drivers/net/ethernet/cadence/macb_pci.c
@@ -128,7 +128,7 @@ static void macb_remove(struct pci_dev *pdev)
 	clk_unregister(plat_data->hclk);
 }
 
-static struct pci_device_id dev_id_table[] = {
+static const struct pci_device_id dev_id_table[] = {
 	{ PCI_DEVICE(CDNS_VENDOR_ID, CDNS_DEVICE_ID), },
 	{ 0, }
 };
-- 
2.7.4
