From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 09/10] isdn: mISDN: hfcpci: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:50 +0530
Message-ID: <1500092751-8291-10-git-send-email-arvind.yadav.cs@gmail.com>
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
  21656	   1024	     96	  22776	   58f8	isdn/hardware/mISDN/hfcpci.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  22424	    256	     96	  22776	   58f8	isdn/hardware/mISDN/hfcpci.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/hfcpci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 5dc246d..d2e401a 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2161,7 +2161,7 @@ static const struct _hfc_map hfc_map[] =
 	{},
 };
 
-static struct pci_device_id hfc_ids[] =
+static const struct pci_device_id hfc_ids[] =
 {
 	{ PCI_VDEVICE(CCD, PCI_DEVICE_ID_CCD_2BD0),
 	  (unsigned long) &hfc_map[0] },
-- 
2.7.4
