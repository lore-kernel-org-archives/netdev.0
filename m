From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 02/10] isdn: hisax: hfc4s8s_l1: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:43 +0530
Message-ID: <1500092751-8291-3-git-send-email-arvind.yadav.cs@gmail.com>
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
  10512	    536	      4	  11052	   2b2c	drivers/isdn/hisax/hfc4s8s_l1.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  10672	    376	      4	  11052	   2b2c	drivers/isdn/hisax/hfc4s8s_l1.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hisax/hfc4s8s_l1.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 90f051c..9090cc1 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -86,7 +86,7 @@ typedef struct {
 	char *device_name;
 } hfc4s8s_param;
 
-static struct pci_device_id hfc4s8s_ids[] = {
+static const struct pci_device_id hfc4s8s_ids[] = {
 	{.vendor = PCI_VENDOR_ID_CCD,
 	 .device = PCI_DEVICE_ID_4S,
 	 .subvendor = 0x1397,
-- 
2.7.4
