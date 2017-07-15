From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 07/10] isdn: mISDN: w6692: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:48 +0530
Message-ID: <1500092751-8291-8-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de, davem@davemloft.net, dhowells@redhat.com,
        johannes.berg@intel.com, mac@melware.de, baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  13959	   4080	     24	  18063	   468f isdn/hardware/mISDN/w6692.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  14087	   3952	     24	  18063	   468f isdn/hardware/mISDN/w6692.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/w6692.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 3052c83..d80072f 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1398,7 +1398,7 @@ w6692_remove_pci(struct pci_dev *pdev)
 			pr_notice("%s: drvdata already removed\n", __func__);
 }
 
-static struct pci_device_id w6692_ids[] = {
+static const struct pci_device_id w6692_ids[] = {
 	{ PCI_VENDOR_ID_DYNALINK, PCI_DEVICE_ID_DYNALINK_IS64PH,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, (ulong)&w6692_map[0]},
 	{ PCI_VENDOR_ID_WINBOND2, PCI_DEVICE_ID_WINBOND2_6692,
-- 
2.7.4
