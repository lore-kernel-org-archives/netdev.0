From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 09/12] atm: zatm: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:37 +0530
Message-ID: <1500197560-14623-10-git-send-email-arvind.yadav.cs@gmail.com>
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
  14350	    352	     40	  14742	   3996	drivers/atm/zatm.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  14446	    256	     40	  14742	   3996	drivers/atm/zatm.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/zatm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 292dec1..d3aa748 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1642,7 +1642,7 @@ static int zatm_init_one(struct pci_dev *pci_dev,
 
 MODULE_LICENSE("GPL");
 
-static struct pci_device_id zatm_pci_tbl[] = {
+static const struct pci_device_id zatm_pci_tbl[] = {
 	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1221), ZATM_COPPER },
 	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1225), 0 },
 	{ 0, }
-- 
2.7.4
