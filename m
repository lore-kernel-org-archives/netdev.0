From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 03/12] atm: fore200e: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:31 +0530
Message-ID: <1500197560-14623-4-git-send-email-arvind.yadav.cs@gmail.com>
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
  20025	    320	     16	  20361	   4f89	drivers/atm/fore200e.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  20089	    256	     16	  20361	   4f89	drivers/atm/fore200e.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/fore200e.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index f0433ad..f8b7e86 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2757,7 +2757,7 @@ static void fore200e_pca_remove_one(struct pci_dev *pci_dev)
 }
 
 
-static struct pci_device_id fore200e_pca_tbl[] = {
+static const struct pci_device_id fore200e_pca_tbl[] = {
     { PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_PCA200E, PCI_ANY_ID, PCI_ANY_ID,
       0, 0, (unsigned long) &fore200e_bus[0] },
     { 0, }
-- 
2.7.4
