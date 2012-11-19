From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 300/493] atm: remove use of __devinitdata
Date: Mon, 19 Nov 2012 13:24:09 -0500
Message-ID: <1353349642-3677-300-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41461 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088Ab2KSSeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:34:24 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinitdata is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/firestream.c | 2 +-
 drivers/atm/nicstar.c    | 2 +-
 drivers/atm/solos-pci.c  | 2 +-
 drivers/atm/zatm.c       | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index a173c77..c8c81e4 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -252,7 +252,7 @@ struct reginit_item {
 };
 
 
-static struct reginit_item PHY_NTC_INIT[] __devinitdata = {
+static struct reginit_item PHY_NTC_INIT[] = {
 	{ PHY_CLEARALL, 0x40 }, 
 	{ 0x12,  0x0001 },
 	{ 0x13,  0x7605 },
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index a6845a0..bc9adf2 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -262,7 +262,7 @@ static void __devexit nicstar_remove_one(struct pci_dev *pcidev)
 	kfree(card);
 }
 
-static struct pci_device_id nicstar_pci_tbl[] __devinitdata = {
+static struct pci_device_id nicstar_pci_tbl[] = {
 	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77201), 0 },
 	{0,}			/* terminate list */
 };
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 9851093..0a346ea 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1328,7 +1328,7 @@ static void fpga_remove(struct pci_dev *dev)
 	kfree(card);
 }
 
-static struct pci_device_id fpga_pci_tbl[] __devinitdata = {
+static struct pci_device_id fpga_pci_tbl[] = {
 	{ 0x10ee, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0, }
 };
diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index 7436362..19624c8 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1636,7 +1636,7 @@ out_free:
 
 MODULE_LICENSE("GPL");
 
-static struct pci_device_id zatm_pci_tbl[] __devinitdata = {
+static struct pci_device_id zatm_pci_tbl[] = {
 	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1221), ZATM_COPPER },
 	{ PCI_VDEVICE(ZEITNET, PCI_DEVICE_ID_ZEITNET_1225), 0 },
 	{ 0, }
-- 
1.8.0
