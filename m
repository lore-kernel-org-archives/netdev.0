From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 1/5] Add KSZ8795 switch driver support in Kconfig
Date: Thu, 7 Sep 2017 21:17:04 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A79@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Add KSZ8795 switch support with SPI access.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/Kconfig
index a8b8f59..0b6225e 100644
--- a/drivers/net/dsa/microchip/Kconfig
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -10,3 +10,21 @@ config MICROCHIP_KSZ_SPI_DRIVER
 	depends on MICROCHIP_KSZ && SPI
 	help
 	  Select to enable support for registering switches configured through SPI.
+
+menuconfig MICROCHIP_KSZ8795
+	tristate "Microchip KSZ8795 series switch support"
+	depends on NET_DSA
+	select NET_DSA_TAG_KSZ
+	help
+	  This driver adds support for Microchip KSZ8795 switch chips.
+
+config MICROCHIP_KSZ8795_SPI_DRIVER
+	tristate "KSZ8795 series SPI connected switch driver"
+	depends on MICROCHIP_KSZ8795 && SPI
+	default y
+	help
+	  This driver accesses KSZ8795 chip through SPI.
+
+	  It is required to use the KSZ8795 switch driver as the only access
+	  is through SPI.
+
