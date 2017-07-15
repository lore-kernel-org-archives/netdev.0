From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 04/10] isdn: eicon: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:45 +0530
Message-ID: <1500092751-8291-5-git-send-email-arvind.yadav.cs@gmail.com>
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
   6224	    655	      8	   6887	   1ae7	isdn/hardware/eicon/divasmain.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   6608	    271	      8	   6887	   1ae7	isdn/hardware/eicon/divasmain.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/eicon/divasmain.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index 8b7ad4f..b2023e0 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -110,7 +110,7 @@ typedef struct _diva_os_thread_dpc {
 /*
   This table should be sorted by PCI device ID
 */
-static struct pci_device_id divas_pci_tbl[] = {
+static const struct pci_device_id divas_pci_tbl[] = {
 	/* Diva Server BRI-2M PCI 0xE010 */
 	{ PCI_VDEVICE(EICON, PCI_DEVICE_ID_EICON_MAESTRA),
 	  CARDTYPE_MAESTRA_PCI },
-- 
2.7.4
