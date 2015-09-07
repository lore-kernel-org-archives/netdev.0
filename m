From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/2] r8152: split DRIVER_VERSION
Date: Mon, 7 Sep 2015 11:57:43 +0800
Message-ID: <1394712342-15778-167-Taiwan-albertk@realtek.com>
References: <1394712342-15778-166-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-166-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Split DRIVER_VERSION into NETNEXT_VERSION and NET_VERSION. Then,
according to the value of DRIVER_VERSION, we could know which
patches are used generally without comparing the source code.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index fe4ec32..6bb48bc 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,8 +26,13 @@
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
 
-/* Version Information */
-#define DRIVER_VERSION "v1.08.1 (2015/07/28)"
+/* Information for net-next */
+#define NETNEXT_VERSION		"08"
+
+/* Information for net */
+#define NET_VERSION		"1"
+
+#define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
-- 
2.4.3
