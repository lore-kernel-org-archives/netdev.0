From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 10/12] atm: firestream: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:38 +0530
Message-ID: <1500197560-14623-11-git-send-email-arvind.yadav.cs@gmail.com>
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
  16884	    444	     28	  17356	   43cc	drivers/atm/firestream.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  16980	    348	     28	  17356	   43cc	drivers/atm/firestream.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/firestream.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 22dcab9..6b6368a 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -2030,7 +2030,7 @@ static void firestream_remove_one(struct pci_dev *pdev)
 	func_exit ();
 }
 
-static struct pci_device_id firestream_pci_tbl[] = {
+static const struct pci_device_id firestream_pci_tbl[] = {
 	{ PCI_VDEVICE(FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS50), FS_IS50},
 	{ PCI_VDEVICE(FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS155), FS_IS155},
 	{ 0, }
-- 
2.7.4
