From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 02/12] atm: ambassador: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:30 +0530
Message-ID: <1500197560-14623-3-git-send-email-arvind.yadav.cs@gmail.com>
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
  13372	    408	      4	  13784	   35d8	drivers/atm/ambassador.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  13484	    296	      4	  13784	   35d8	drivers/atm/ambassador.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/ambassador.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 906705e..acf16c3 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2374,7 +2374,7 @@ MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 
 /********** module entry **********/
 
-static struct pci_device_id amb_pci_tbl[] = {
+static const struct pci_device_id amb_pci_tbl[] = {
 	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR), 0 },
 	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD), 0 },
 	{ 0, }
-- 
2.7.4
