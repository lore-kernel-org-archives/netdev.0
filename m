From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 08/25] atm: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 20:45:32 +0200
Message-ID: <201007152045.33543.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	"David S. Miller" <davem@davemloft.net>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	Tejun Heo <tj@kernel.org>,
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
 drivers/atm/idt77252.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 558ad18..1679cbf 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3779,8 +3779,7 @@ err_out_disable_pdev:
 
 static struct pci_device_id idt77252_pci_tbl[] =
 {
-	{ PCI_VENDOR_ID_IDT, PCI_DEVICE_ID_IDT_IDT77252,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ PCI_VDEVICE(IDT, PCI_DEVICE_ID_IDT_IDT77252), 0 },
 	{ 0, }
 };
 
-- 
1.7.1
