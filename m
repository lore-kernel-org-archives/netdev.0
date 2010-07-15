From: Peter Huewe <PeterHuewe@gmx.de>
Subject: [PATCH 07/25] atm: Convert pci_table entries to PCI_VDEVICE (if PCI_ANY_ID is used)
Date: Thu, 15 Jul 2010 20:44:11 +0200
Message-ID: <201007152044.12653.PeterHuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	"David S. Miller" <davem@davemloft.net>,
	Roel Kluin <roel.kluin@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
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
 drivers/atm/he.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index fa4d600..801e8b6 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2870,8 +2870,7 @@ module_param(sdh, bool, 0);
 MODULE_PARM_DESC(sdh, "use SDH framing (default 0)");
 
 static struct pci_device_id he_pci_tbl[] = {
-	{ PCI_VENDOR_ID_FORE, PCI_DEVICE_ID_FORE_HE, PCI_ANY_ID, PCI_ANY_ID,
-	  0, 0, 0 },
+	{ PCI_VDEVICE(FORE, PCI_DEVICE_ID_FORE_HE), 0 },
 	{ 0, }
 };
 
-- 
1.7.1
