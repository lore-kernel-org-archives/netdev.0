From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/3] r8152: change the descriptor
Date: Wed, 15 Jan 2014 10:42:14 +0800
Message-ID: <1389753736-2218-2-git-send-email-hayeswang@realtek.com>
References: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
 <1389753736-2218-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389753736-2218-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The r8152 could support RTL8153. Update the relative descriptor.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/Kconfig | 5 +++--
 drivers/net/usb/r8152.c | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 47b0f73..6b638a0 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -92,11 +92,12 @@ config USB_RTL8150
 	  module will be called rtl8150.
 
 config USB_RTL8152
-	tristate "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
+	tristate "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 	select MII
 	help
 	  This option adds support for Realtek RTL8152 based USB 2.0
-	  10/100 Ethernet adapters.
+	  10/100 Ethernet adapters and RTL8153 based USB 3.0 10/100/1000
+	  Ethernet adapters.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called r8152.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index bf7d549..38f3c14 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,7 +26,7 @@
 /* Version Information */
 #define DRIVER_VERSION "v1.03.0 (2013/12/26)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
-#define DRIVER_DESC "Realtek RTL8152 Based USB 2.0 Ethernet Adapters"
+#define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
 
 #define R8152_PHY_ID		32
-- 
1.8.4.2
