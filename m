From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v4 12/12] ARM: orion5x: remove legacy mv643xx_eth board setup
Date: Tue, 21 May 2013 18:41:50 +0200
Message-ID: <1369154510-4927-13-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With DT support for mv643xx_eth we do not need legacy platform_data
based setup for DT enabled boards. This patch removes eth setup
for all orion5x DT board files.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David Miller <davem@davemloft.net>
Cc: Lennert Buytenhek <buytenh@wantstofly.org>
Cc: Jason Cooper <jason@lakedaemon.net>
Cc: Andrew Lunn <andrew@lunn.ch>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/mach-orion5x/edmini_v2-setup.c |   10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/arm/mach-orion5x/edmini_v2-setup.c b/arch/arm/mach-orion5x/edmini_v2-setup.c
index 1476155..d9de926 100644
--- a/arch/arm/mach-orion5x/edmini_v2-setup.c
+++ b/arch/arm/mach-orion5x/edmini_v2-setup.c
@@ -24,7 +24,6 @@
 #include <linux/pci.h>
 #include <linux/irq.h>
 #include <linux/mtd/physmap.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/leds.h>
 #include <linux/gpio_keys.h>
 #include <linux/input.h>
@@ -96,14 +95,6 @@ static struct platform_device edmini_v2_nor_flash = {
 };
 
 /*****************************************************************************
- * Ethernet
- ****************************************************************************/
-
-static struct mv643xx_eth_platform_data edmini_v2_eth_data = {
-	.phy_addr	= 8,
-};
-
-/*****************************************************************************
  * RTC 5C372a on I2C bus
  ****************************************************************************/
 
@@ -152,7 +143,6 @@ void __init edmini_v2_init(void)
 	 * Configure peripherals.
 	 */
 	orion5x_ehci0_init();
-	orion5x_eth_init(&edmini_v2_eth_data);
 
 	mvebu_mbus_add_window("devbus-boot", EDMINI_V2_NOR_BOOT_BASE,
 			      EDMINI_V2_NOR_BOOT_SIZE);
-- 
1.7.10.4
