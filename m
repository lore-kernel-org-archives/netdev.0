From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 01/12] atm: iphase: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:29 +0530
Message-ID: <1500197560-14623-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
To: 3chas3@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  23536	    432	    160	  24128	   5e40	drivers/atm/iphase.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  23632	    336	    160	  24128	   5e40	drivers/atm/iphase.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/iphase.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index a4fa6c8..fc72b76 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3266,7 +3266,7 @@ static void ia_remove_one(struct pci_dev *pdev)
       	kfree(iadev);
 }
 
-static struct pci_device_id ia_pci_tbl[] = {
+static const struct pci_device_id ia_pci_tbl[] = {
 	{ PCI_VENDOR_ID_IPHASE, 0x0008, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_IPHASE, 0x0009, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
-- 
2.7.4
