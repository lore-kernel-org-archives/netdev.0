From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v5 3/8] thunderbolt: Kconfig for Thunderbolt(TM) networking
Date: Thu, 28 Jul 2016 11:15:16 +0300
Message-ID: <1469693721-5641-4-git-send-email-amir.jer.levy@intel.com>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	netdev@vger.kernel.org, linux-doc@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com, Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updating the Kconfig Thunderbolt(TM) description.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 drivers/thunderbolt/Kconfig  | 25 +++++++++++++++++++++----
 drivers/thunderbolt/Makefile |  2 +-
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/drivers/thunderbolt/Kconfig b/drivers/thunderbolt/Kconfig
index c121acc..d34b0f5 100644
--- a/drivers/thunderbolt/Kconfig
+++ b/drivers/thunderbolt/Kconfig
@@ -1,13 +1,30 @@
-menuconfig THUNDERBOLT
-	tristate "Thunderbolt support for Apple devices"
+config THUNDERBOLT
+	tristate "Thunderbolt(TM) support"
 	depends on PCI
 	select CRC32
 	help
-	  Cactus Ridge Thunderbolt Controller driver
+	  Thunderbolt(TM) Controller driver
+
+if THUNDERBOLT
+
+config THUNDERBOLT_APPLE
+	tristate "Apple hardware support"
+	help
 	  This driver is required if you want to hotplug Thunderbolt devices on
 	  Apple hardware.
 
 	  Device chaining is currently not supported.
 
-	  To compile this driver a module, choose M here. The module will be
+	  To compile this driver as a module, choose M here. The module will be
 	  called thunderbolt.
+
+config THUNDERBOLT_ICM
+	tristate "Thunderbolt(TM) Networking"
+	help
+	  This driver is required if you want Thunderbolt(TM) Networking on
+	  non-Apple hardware.
+
+	  To compile this driver as a module, choose M here. The module will be
+	  called thunderbolt_icm.
+
+endif
diff --git a/drivers/thunderbolt/Makefile b/drivers/thunderbolt/Makefile
index 5d1053c..7a85bd1 100644
--- a/drivers/thunderbolt/Makefile
+++ b/drivers/thunderbolt/Makefile
@@ -1,3 +1,3 @@
-obj-${CONFIG_THUNDERBOLT} := thunderbolt.o
+obj-${CONFIG_THUNDERBOLT_APPLE} := thunderbolt.o
 thunderbolt-objs := nhi.o ctl.o tb.o switch.o cap.o path.o tunnel_pci.o eeprom.o
 
-- 
2.7.4

