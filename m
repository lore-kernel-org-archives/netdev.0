From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 06/10] isdn: mISDN: hfcmulti: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:47 +0530
Message-ID: <1500092751-8291-7-git-send-email-arvind.yadav.cs@gmail.com>
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
  63450	   1536	   1492	  66478	  103ae	isdn/hardware/mISDN/hfcmulti.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  64698	    288	   1492	  66478	  103ae	isdn/hardware/mISDN/hfcmulti.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index aea0c96..3cf07b8 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -5348,7 +5348,7 @@ static const struct hm_map hfcm_map[] = {
 
 #undef H
 #define H(x)	((unsigned long)&hfcm_map[x])
-static struct pci_device_id hfmultipci_ids[] = {
+static const struct pci_device_id hfmultipci_ids[] = {
 
 	/* Cards with HFC-4S Chip */
 	{ PCI_VENDOR_ID_CCD, PCI_DEVICE_ID_CCD_HFC4S, PCI_VENDOR_ID_CCD,
-- 
2.7.4
