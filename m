From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 04/12] atm: nicstar: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:32 +0530
Message-ID: <1500197560-14623-5-git-send-email-arvind.yadav.cs@gmail.com>
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
  22781	    464	    128	  23373	   5b4d	drivers/atm/nicstar.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  22845	    400	    128	  23373	   5b4d	drivers/atm/nicstar.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/nicstar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index d879f3b..9588d80 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -253,7 +253,7 @@ static void nicstar_remove_one(struct pci_dev *pcidev)
 	kfree(card);
 }
 
-static struct pci_device_id nicstar_pci_tbl[] = {
+static const struct pci_device_id nicstar_pci_tbl[] = {
 	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77201), 0 },
 	{0,}			/* terminate list */
 };
-- 
2.7.4
