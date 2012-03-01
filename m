From: Cloud Ren <cjren@qca.qualcomm.com>
Subject: [PATCH 3/3] atl1c: refine driver description
Date: Thu, 1 Mar 2012 13:41:09 +0800
Message-ID: <1330580469-23348-4-git-send-email-cjren@qca.qualcomm.com>
References: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	Cloud Ren <cjren@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330580469-23348-1-git-send-email-cjren@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refine driver description make it more precise. And add a print information,
when loading driver.

Signed-off-by: Cloud Ren <cjren@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 815f683..1d5218a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -22,6 +22,9 @@
 #include "atl1c.h"
 
 char atl1c_driver_name[] = "atl1c";
+static const char atl1c_drv_description[] =
+	"Qualcomm Atheros(R) AR813x/AR815x PCI-E Ethernet Network Driver";
+
 #define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
 #define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063
 #define PCI_DEVICE_ID_ATHEROS_L2C_B	0x2060 /* AR8152 v1.1 Fast 10/100 */
@@ -53,7 +56,7 @@ static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
 MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
 
 MODULE_AUTHOR("Qualcomm Corporation, <nic-devel@qualcomm.com>");
-MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
+MODULE_DESCRIPTION("Qualcomm Atheros Gigabit Ethernet Driver");
 MODULE_LICENSE("GPL");
 
 static int atl1c_stop_mac(struct atl1c_hw *hw);
@@ -2907,6 +2910,7 @@ static struct pci_driver atl1c_driver = {
  */
 static int __init atl1c_init_module(void)
 {
+	pr_info("%s\n", atl1c_drv_description);
 	return pci_register_driver(&atl1c_driver);
 }
 
-- 
1.7.7
