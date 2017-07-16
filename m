From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 08/12] atm: lanai: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:36 +0530
Message-ID: <1500197560-14623-9-git-send-email-arvind.yadav.cs@gmail.com>
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
  18074	    352	      0	  18426	   47fa	drivers/atm/lanai.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  18170	    256	      0	  18426	   47fa	drivers/atm/lanai.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/lanai.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 1a9bc51..2351dad 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2589,7 +2589,7 @@ static int lanai_init_one(struct pci_dev *pci,
 	return result;
 }
 
-static struct pci_device_id lanai_pci_tbl[] = {
+static const struct pci_device_id lanai_pci_tbl[] = {
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAI2) },
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_LANAIHB) },
 	{ 0, }	/* terminal entry */
-- 
2.7.4
