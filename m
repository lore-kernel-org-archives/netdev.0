From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 07/12] atm: solos-pci: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:35 +0530
Message-ID: <1500197560-14623-8-git-send-email-arvind.yadav.cs@gmail.com>
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
  16138	   4592	     24	  20754	   5112	drivers/atm/solos-pci.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  16218	   4528	     24	  20754	   5122	drivers/atm/solos-pci.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/solos-pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c8f2ca6..585984e 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1476,7 +1476,7 @@ static void fpga_remove(struct pci_dev *dev)
 	kfree(card);
 }
 
-static struct pci_device_id fpga_pci_tbl[] = {
+static const struct pci_device_id fpga_pci_tbl[] = {
 	{ 0x10ee, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0, }
 };
-- 
2.7.4
