From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v2 2/8] thunderbolt: Updating device IDs
Date: Wed, 29 Jun 2016 11:35:30 +0300
Message-ID: <1467189336-29556-3-git-send-email-amir.jer.levy@intel.com>
References: <1467189336-29556-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com,
	Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467189336-29556-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding the new Thunderbolt(TM) device IDs to the list.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 include/linux/pci_ids.h | 44 ++++++++++++++++++++++++++------------------
 1 file changed, 26 insertions(+), 18 deletions(-)

diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index c58752f..2d4cc50 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2604,24 +2604,32 @@
 #define PCI_DEVICE_ID_INTEL_82441	0x1237
 #define PCI_DEVICE_ID_INTEL_82380FB	0x124b
 #define PCI_DEVICE_ID_INTEL_82439	0x1250
-#define PCI_DEVICE_ID_INTEL_LIGHT_RIDGE             0x1513 /* Tbt 1 Gen 1 */
-#define PCI_DEVICE_ID_INTEL_EAGLE_RIDGE             0x151a
-#define PCI_DEVICE_ID_INTEL_LIGHT_PEAK              0x151b
-#define PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_4C         0x1547 /* Tbt 1 Gen 2 */
-#define PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_2C         0x1548
-#define PCI_DEVICE_ID_INTEL_PORT_RIDGE              0x1549
-#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_2C_NHI    0x1566 /* Tbt 1 Gen 3 */
-#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_2C_BRIDGE 0x1567
-#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_4C_NHI    0x1568
-#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_4C_BRIDGE 0x1569
-#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_2C_NHI     0x156a /* Thunderbolt 2 */
-#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_2C_BRIDGE  0x156b
-#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_4C_NHI     0x156c
-#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_4C_BRIDGE  0x156d
-#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_2C_NHI     0x1575 /* Thunderbolt 3 */
-#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_2C_BRIDGE  0x1576
-#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_4C_NHI     0x1577
-#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_4C_BRIDGE  0x1578
+#define PCI_DEVICE_ID_INTEL_LIGHT_RIDGE              0x1513 /* Tbt 1 Gen 1 */
+#define PCI_DEVICE_ID_INTEL_EAGLE_RIDGE              0x151a
+#define PCI_DEVICE_ID_INTEL_LIGHT_PEAK               0x151b
+#define PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_4C          0x1547 /* Tbt 1 Gen 2 */
+#define PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_2C          0x1548
+#define PCI_DEVICE_ID_INTEL_PORT_RIDGE               0x1549
+#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_2C_NHI     0x1566 /* Tbt 1 Gen 3 */
+#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_2C_BRIDGE  0x1567
+#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_4C_NHI     0x1568
+#define PCI_DEVICE_ID_INTEL_REDWOOD_RIDGE_4C_BRIDGE  0x1569
+#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_2C_NHI      0x156a /* Thunderbolt 2 */
+#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_2C_BRIDGE   0x156b
+#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_4C_NHI      0x156c
+#define PCI_DEVICE_ID_INTEL_FALCON_RIDGE_4C_BRIDGE   0x156d
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_2C_NHI      0x1575 /* Thunderbolt 3 */
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_2C_BRIDGE   0x1576
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_4C_NHI      0x1577
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_4C_BRIDGE   0x1578
+#define PCI_DEVICE_ID_INTEL_WIN_RIDGE_2C_NHI         0x157d /* Tbt 2 Low Pwr */
+#define PCI_DEVICE_ID_INTEL_WIN_RIDGE_2C_BRIDGE      0x157e
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_LP_NHI      0x15bf /* Tbt 3 Low Pwr */
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_LP_BRIDGE   0x15c0
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_C_4C_NHI    0x15d2 /* Thunderbolt 3 */
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_C_4C_BRIDGE 0x15d3
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_C_2C_NHI    0x15d9
+#define PCI_DEVICE_ID_INTEL_ALPINE_RIDGE_C_2C_BRIDGE 0x15da
 #define PCI_DEVICE_ID_INTEL_80960_RP	0x1960
 #define PCI_DEVICE_ID_INTEL_82840_HB	0x1a21
 #define PCI_DEVICE_ID_INTEL_82845_HB	0x1a30
-- 
2.7.4
