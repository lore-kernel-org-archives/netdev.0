From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 05/12] atm: he: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:33 +0530
Message-ID: <1500197560-14623-6-git-send-email-arvind.yadav.cs@gmail.com>
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
  26514	    440	     48	  27002	   697a	drivers/atm/he.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  26578	    376	     48	  27002	   697a	drivers/atm/he.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/he.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index 37ee21c..8f6156d 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2851,7 +2851,7 @@ MODULE_PARM_DESC(irq_coalesce, "use interrupt coalescing (default 1)");
 module_param(sdh, bool, 0);
 MODULE_PARM_DESC(sdh, "use SDH framing (default 0)");
 
-static struct pci_device_id he_pci_tbl[] = {
+static const struct pci_device_id he_pci_tbl[] = {
 	{ PCI_VDEVICE(FORE, PCI_DEVICE_ID_FORE_HE), 0 },
 	{ 0, }
 };
-- 
2.7.4
