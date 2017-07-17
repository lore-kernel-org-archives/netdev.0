From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 09/11] net: ec_bhf: constify pci_device_id.
Date: Mon, 17 Jul 2017 23:42:34 +0530
Message-ID: <1500315154-3304-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: reksio@newterm.pl, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   5113	    384	      0	   5497	   1579	drivers/net/ethernet/ec_bhf.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   5177	    320	      0	   5497	   1579	drivers/net/ethernet/ec_bhf.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/ec_bhf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 4ee042c..1b79a6d 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -73,7 +73,7 @@
 
 #define ETHERCAT_MASTER_ID	0x14
 
-static struct pci_device_id ids[] = {
+static const struct pci_device_id ids[] = {
 	{ PCI_DEVICE(0x15ec, 0x5000), },
 	{ 0, }
 };
-- 
2.7.4
