From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 10/10] isdn: avm: c4: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:51 +0530
Message-ID: <1500092751-8291-11-git-send-email-arvind.yadav.cs@gmail.com>
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
  11803	    544	      1	  12348	   303c	isdn/hardware/avm/c4.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  11931	    416	      1	  12348	   303c	isdn/hardware/avm/c4.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/avm/c4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 40c7e2c..034caba 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -42,7 +42,7 @@ static char *revision = "$Revision: 1.1.2.2 $";
 
 static bool suppress_pollack;
 
-static struct pci_device_id c4_pci_tbl[] = {
+static const struct pci_device_id c4_pci_tbl[] = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_21285, PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_C4, 0, 0, (unsigned long)4 },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_21285, PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_C2, 0, 0, (unsigned long)2 },
 	{ }			/* Terminating entry */
-- 
2.7.4
