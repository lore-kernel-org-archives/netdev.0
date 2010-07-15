From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 03/25] atm: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 20:38:20 +0200
Message-ID: <201007152038.21535.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>, Tejun Heo <tj@kernel.org>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kernel Janitors <kernel-janitors@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Huewe <peterhuewe@gmx.de>

This patch converts pci_table entries, where .subvendor=PCI_ANY_ID and
.subdevice=PCI_ANY_ID, .class=0 and .class_mask=0, to use the
PCI_VDEVICE macro, and thus improves readability.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/atm/ambassador.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 9d18644..a33896a 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2371,10 +2371,8 @@ MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 /********** module entry **********/
 
 static struct pci_device_id amb_pci_tbl[] = {
-	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
-	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
+	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR), 0 },
+	{ PCI_VDEVICE(MADGE, PCI_DEVICE_ID_MADGE_AMBASSADOR_BAD), 0 },
 	{ 0, }
 };
 
-- 
1.7.1
