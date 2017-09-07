From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Thu, 7 Sep 2017 21:08:58 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Break ksz_common.c into 2 files so that the common code can be used by other KSZ switch drivers.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
index ed335e2..0961c30 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -1,2 +1,2 @@
-obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz9477.o ksz_common.o
 obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
