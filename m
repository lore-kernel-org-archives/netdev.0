From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 03/10] isdn: hisax: hisax_fcpcipnp: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:44 +0530
Message-ID: <1500092751-8291-4-git-send-email-arvind.yadav.cs@gmail.com>
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
   5989	    576	      0	   6565	   19a5 isdn/hisax/hisax_fcpcipnp.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   6085	    480	      0	   6565	   19a5 isdn/hisax/hisax_fcpcipnp.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hisax/hisax_fcpcipnp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/hisax_fcpcipnp.c b/drivers/isdn/hisax/hisax_fcpcipnp.c
index 5a9f39e..e4f7573 100644
--- a/drivers/isdn/hisax/hisax_fcpcipnp.c
+++ b/drivers/isdn/hisax/hisax_fcpcipnp.c
@@ -52,7 +52,7 @@ module_param(debug, int, 0);
 MODULE_AUTHOR("Kai Germaschewski <kai.germaschewski@gmx.de>/Karsten Keil <kkeil@suse.de>");
 MODULE_DESCRIPTION("AVM Fritz!PCI/PnP ISDN driver");
 
-static struct pci_device_id fcpci_ids[] = {
+static const struct pci_device_id fcpci_ids[] = {
 	{ .vendor      = PCI_VENDOR_ID_AVM,
 	  .device      = PCI_DEVICE_ID_AVM_A1,
 	  .subvendor   = PCI_ANY_ID,
-- 
2.7.4
