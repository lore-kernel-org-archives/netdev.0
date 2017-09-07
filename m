From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 2/5] Add KSZ8795 switch driver support in Makefile
Date: Thu, 7 Sep 2017 21:17:10 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A80@CHN-SV-EXMX02.mchp-main.com>
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
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
index 0961c30..0d8ba48 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -1,2 +1,4 @@
 obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz9477.o ksz_common.o
 obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
+obj-$(CONFIG_MICROCHIP_KSZ8795)	        += ksz8795.o ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ8795_SPI_DRIVER)	+= ksz8795_spi.o
