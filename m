From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 4/7] Rename ksz_spi.c to ksz9477_spi.c
Date: Fri, 6 Oct 2017 13:33:02 -0700
Message-ID: <1507321985-15097-5-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Rename ksz_spi.c to ksz9477_spi.c and update Kconfig in preparation to add
more KSZ switch drivers.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/Kconfig                      | 12 ++++++------
 drivers/net/dsa/microchip/Makefile                     |  4 ++--
 drivers/net/dsa/microchip/{ksz_spi.c => ksz9477_spi.c} |  0
 3 files changed, 8 insertions(+), 8 deletions(-)
 rename drivers/net/dsa/microchip/{ksz_spi.c => ksz9477_spi.c} (100%)

diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/Kconfig
index a8b8f59..5a8660d 100644
--- a/drivers/net/dsa/microchip/Kconfig
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -1,12 +1,12 @@
-menuconfig MICROCHIP_KSZ
-	tristate "Microchip KSZ series switch support"
+menuconfig MICROCHIP_KSZ9477
+	tristate "Microchip KSZ9477 series switch support"
 	depends on NET_DSA
 	select NET_DSA_TAG_KSZ
 	help
-	  This driver adds support for Microchip KSZ switch chips.
+	  This driver adds support for Microchip KSZ9477 switch chips.
 
-config MICROCHIP_KSZ_SPI_DRIVER
-	tristate "KSZ series SPI connected switch driver"
-	depends on MICROCHIP_KSZ && SPI
+config MICROCHIP_KSZ9477_SPI_DRIVER
+	tristate "KSZ9477 series SPI connected switch driver"
+	depends on MICROCHIP_KSZ9477 && SPI
 	help
 	  Select to enable support for registering switches configured through SPI.
diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
index ed335e2..5b6325b 100644
--- a/drivers/net/dsa/microchip/Makefile
+++ b/drivers/net/dsa/microchip/Makefile
@@ -1,2 +1,2 @@
-obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz_common.o
-obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o
+obj-$(CONFIG_MICROCHIP_KSZ9477)	        += ksz_common.o
+obj-$(CONFIG_MICROCHIP_KSZ9477_SPI_DRIVER)	+= ksz9477_spi.o
diff --git a/drivers/net/dsa/microchip/ksz_spi.c b/drivers/net/dsa/microchip/ksz9477_spi.c
similarity index 100%
rename from drivers/net/dsa/microchip/ksz_spi.c
rename to drivers/net/dsa/microchip/ksz9477_spi.c
-- 
1.9.1
