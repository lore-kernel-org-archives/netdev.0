From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 5/7] ARM: kirkwood: remove legacy mv643xx_eth board setup
Date: Mon,  6 May 2013 17:33:38 +0200
Message-ID: <1367854420-8006-6-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>, Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>,
 Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
 Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Willy Tarreau <w@1wt.eu>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

With DT support for mv643xx_eth we do not need legacy platform_data
based setup for DT enabled boards. This patch removes eth setup
for all kirkwood DT board files.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Cc: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>
Cc: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Cc: Michael Walle <michael-QKn5cuLxLXY@public.gmane.org>
Cc: Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Willy Tarreau <w@1wt.eu>
Cc: Simon Baatz <gmbnomis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>
Cc: Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Cc: Stefan Peter <s.peter-R0yVo0h44Ow@public.gmane.org>
Cc: Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>
Cc: Nobuhiro Iwamatsu <iwamatsu-+mkmVskJBflAfugRpC6u6w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/arm/mach-kirkwood/board-dnskw.c          |    7 -------
 arch/arm/mach-kirkwood/board-dockstar.c       |    9 ---------
 arch/arm/mach-kirkwood/board-dreamplug.c      |   14 --------------
 arch/arm/mach-kirkwood/board-goflexnet.c      |    9 ---------
 arch/arm/mach-kirkwood/board-guruplug.c       |   14 --------------
 arch/arm/mach-kirkwood/board-ib62x0.c         |    9 ---------
 arch/arm/mach-kirkwood/board-iconnect.c       |    6 ------
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c |   16 ----------------
 arch/arm/mach-kirkwood/board-km_kirkwood.c    |    7 -------
 arch/arm/mach-kirkwood/board-lsxl.c           |   12 ------------
 arch/arm/mach-kirkwood/board-mplcec4.c        |   11 -----------
 arch/arm/mach-kirkwood/board-ns2.c            |   13 -------------
 arch/arm/mach-kirkwood/board-openblocks_a6.c  |    9 ---------
 arch/arm/mach-kirkwood/board-readynas.c       |    6 ------
 arch/arm/mach-kirkwood/board-ts219.c          |   13 -------------
 arch/arm/mach-kirkwood/board-usi_topkick.c    |    9 ---------
 16 files changed, 0 insertions(+), 164 deletions(-)

diff --git a/arch/arm/mach-kirkwood/board-dnskw.c b/arch/arm/mach-kirkwood/board-dnskw.c
index a1aa87f..2af7a95 100644
--- a/arch/arm/mach-kirkwood/board-dnskw.c
+++ b/arch/arm/mach-kirkwood/board-dnskw.c
@@ -14,14 +14,9 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data dnskw_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 /* Register any GPIO for output and set the value */
 static void __init dnskw_gpio_register(unsigned gpio, char *name, int def)
 {
@@ -36,8 +31,6 @@ static void __init dnskw_gpio_register(unsigned gpio, char *name, int def)
 
 void __init dnskw_init(void)
 {
-	kirkwood_ge00_init(&dnskw_ge00_data);
-
 	/* Set NAS to turn back on after a power failure */
 	dnskw_gpio_register(37, "dnskw:power:recover", 1);
 }
diff --git a/arch/arm/mach-kirkwood/board-dockstar.c b/arch/arm/mach-kirkwood/board-dockstar.c
index d7196db..b78032e 100644
--- a/arch/arm/mach-kirkwood/board-dockstar.c
+++ b/arch/arm/mach-kirkwood/board-dockstar.c
@@ -16,17 +16,8 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data dockstar_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init dockstar_dt_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&dockstar_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-dreamplug.c b/arch/arm/mach-kirkwood/board-dreamplug.c
index 0903242..cb7823d 100644
--- a/arch/arm/mach-kirkwood/board-dreamplug.c
+++ b/arch/arm/mach-kirkwood/board-dreamplug.c
@@ -13,23 +13,9 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data dreamplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data dreamplug_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
 void __init dreamplug_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&dreamplug_ge00_data);
-	kirkwood_ge01_init(&dreamplug_ge01_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-goflexnet.c b/arch/arm/mach-kirkwood/board-goflexnet.c
index 9db979a..4213e20 100644
--- a/arch/arm/mach-kirkwood/board-goflexnet.c
+++ b/arch/arm/mach-kirkwood/board-goflexnet.c
@@ -18,17 +18,8 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data goflexnet_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init goflexnet_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&goflexnet_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-guruplug.c b/arch/arm/mach-kirkwood/board-guruplug.c
index a857163..d515f64 100644
--- a/arch/arm/mach-kirkwood/board-guruplug.c
+++ b/arch/arm/mach-kirkwood/board-guruplug.c
@@ -11,23 +11,9 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data guruplug_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data guruplug_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
 void __init guruplug_dt_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&guruplug_ge00_data);
-	kirkwood_ge01_init(&guruplug_ge01_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-ib62x0.c b/arch/arm/mach-kirkwood/board-ib62x0.c
index 9a857ae..6082373 100644
--- a/arch/arm/mach-kirkwood/board-ib62x0.c
+++ b/arch/arm/mach-kirkwood/board-ib62x0.c
@@ -13,17 +13,8 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data ib62x0_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 void __init ib62x0_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&ib62x0_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-iconnect.c b/arch/arm/mach-kirkwood/board-iconnect.c
index c8ebde4..045668c 100644
--- a/arch/arm/mach-kirkwood/board-iconnect.c
+++ b/arch/arm/mach-kirkwood/board-iconnect.c
@@ -11,16 +11,10 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/of.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data iconnect_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(11),
-};
-
 void __init iconnect_init(void)
 {
-	kirkwood_ge00_init(&iconnect_ge00_data);
 }
 
 static int __init iconnect_pci_init(void)
diff --git a/arch/arm/mach-kirkwood/board-iomega_ix2_200.c b/arch/arm/mach-kirkwood/board-iomega_ix2_200.c
index e5f7041..dc86cf7 100644
--- a/arch/arm/mach-kirkwood/board-iomega_ix2_200.c
+++ b/arch/arm/mach-kirkwood/board-iomega_ix2_200.c
@@ -10,25 +10,9 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/ethtool.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data iomega_ix2_200_ge00_data = {
-	.phy_addr       = MV643XX_ETH_PHY_NONE,
-	.speed          = SPEED_1000,
-	.duplex         = DUPLEX_FULL,
-};
-
-static struct mv643xx_eth_platform_data iomega_ix2_200_ge01_data = {
-        .phy_addr       = MV643XX_ETH_PHY_ADDR(11),
-};
-
 void __init iomega_ix2_200_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&iomega_ix2_200_ge00_data);
-	kirkwood_ge01_init(&iomega_ix2_200_ge01_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-km_kirkwood.c b/arch/arm/mach-kirkwood/board-km_kirkwood.c
index 44e4605..6b8464b 100644
--- a/arch/arm/mach-kirkwood/board-km_kirkwood.c
+++ b/arch/arm/mach-kirkwood/board-km_kirkwood.c
@@ -14,15 +14,10 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/clk.h>
 #include <linux/clk-private.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data km_kirkwood_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init km_kirkwood_init(void)
 {
 	struct clk *sata_clk;
@@ -39,6 +34,4 @@ void __init km_kirkwood_init(void)
 	sata_clk = clk_get_sys("sata_mv.0", "1");
 	if (!IS_ERR(sata_clk))
 		sata_clk->flags |= CLK_IGNORE_UNUSED;
-
-	kirkwood_ge00_init(&km_kirkwood_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-lsxl.c b/arch/arm/mach-kirkwood/board-lsxl.c
index 4ec8b7a..1cbcd56 100644
--- a/arch/arm/mach-kirkwood/board-lsxl.c
+++ b/arch/arm/mach-kirkwood/board-lsxl.c
@@ -14,17 +14,8 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data lsxl_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
-static struct mv643xx_eth_platform_data lsxl_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 /*
  * On the LS-XHL/LS-CHLv2, the shutdown process is following:
  * - Userland monitors key events until the power switch goes to off position
@@ -44,9 +35,6 @@ void __init lsxl_init(void)
 	 * Basic setup. Needs to be called early.
 	 */
 
-	kirkwood_ge00_init(&lsxl_ge00_data);
-	kirkwood_ge01_init(&lsxl_ge01_data);
-
 	/* register power-off method */
 	pm_power_off = lsxl_power_off;
 }
diff --git a/arch/arm/mach-kirkwood/board-mplcec4.c b/arch/arm/mach-kirkwood/board-mplcec4.c
index 7d6dc66..a337ef5 100644
--- a/arch/arm/mach-kirkwood/board-mplcec4.c
+++ b/arch/arm/mach-kirkwood/board-mplcec4.c
@@ -11,24 +11,13 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data mplcec4_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(1),
-};
-
-static struct mv643xx_eth_platform_data mplcec4_ge01_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(2),
-};
-
 void __init mplcec4_init(void)
 {
 	/*
 	 * Basic setup. Needs to be called early.
 	 */
-	kirkwood_ge00_init(&mplcec4_ge00_data);
-	kirkwood_ge01_init(&mplcec4_ge01_data);
 	kirkwood_pcie_init(KW_PCIE0);
 }
 
diff --git a/arch/arm/mach-kirkwood/board-ns2.c b/arch/arm/mach-kirkwood/board-ns2.c
index f8f6605..ba3abd6 100644
--- a/arch/arm/mach-kirkwood/board-ns2.c
+++ b/arch/arm/mach-kirkwood/board-ns2.c
@@ -14,22 +14,9 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/of.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data ns2_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 void __init ns2_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	if (of_machine_is_compatible("lacie,cloudbox") ||
-	    of_machine_is_compatible("lacie,netspace_lite_v2") ||
-	    of_machine_is_compatible("lacie,netspace_mini_v2"))
-		ns2_ge00_data.phy_addr = MV643XX_ETH_PHY_ADDR(0);
-	kirkwood_ge00_init(&ns2_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-openblocks_a6.c b/arch/arm/mach-kirkwood/board-openblocks_a6.c
index b11d8fd..120dccf 100644
--- a/arch/arm/mach-kirkwood/board-openblocks_a6.c
+++ b/arch/arm/mach-kirkwood/board-openblocks_a6.c
@@ -10,17 +10,8 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data openblocks_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init openblocks_a6_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&openblocks_ge00_data);
 }
diff --git a/arch/arm/mach-kirkwood/board-readynas.c b/arch/arm/mach-kirkwood/board-readynas.c
index fb42c20..3ab3e0e 100644
--- a/arch/arm/mach-kirkwood/board-readynas.c
+++ b/arch/arm/mach-kirkwood/board-readynas.c
@@ -13,16 +13,10 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <mach/kirkwood.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data netgear_readynas_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init netgear_readynas_init(void)
 {
-	kirkwood_ge00_init(&netgear_readynas_ge00_data);
 	kirkwood_pcie_init(KW_PCIE0);
 }
diff --git a/arch/arm/mach-kirkwood/board-ts219.c b/arch/arm/mach-kirkwood/board-ts219.c
index acb0187..854d448 100644
--- a/arch/arm/mach-kirkwood/board-ts219.c
+++ b/arch/arm/mach-kirkwood/board-ts219.c
@@ -18,27 +18,14 @@
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
-#include <linux/mv643xx_eth.h>
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
 #include <mach/kirkwood.h>
 #include "common.h"
 #include "tsx1x-common.h"
 
-static struct mv643xx_eth_platform_data qnap_ts219_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(8),
-};
-
 void __init qnap_dt_ts219_init(void)
 {
-	u32 dev, rev;
-
-	kirkwood_pcie_id(&dev, &rev);
-	if (dev == MV88F6282_DEV_ID)
-		qnap_ts219_ge00_data.phy_addr = MV643XX_ETH_PHY_ADDR(0);
-
-	kirkwood_ge00_init(&qnap_ts219_ge00_data);
-
 	pm_power_off = qnap_tsx1x_power_off;
 }
 
diff --git a/arch/arm/mach-kirkwood/board-usi_topkick.c b/arch/arm/mach-kirkwood/board-usi_topkick.c
index 1cc04ec..44a8a6b 100644
--- a/arch/arm/mach-kirkwood/board-usi_topkick.c
+++ b/arch/arm/mach-kirkwood/board-usi_topkick.c
@@ -12,18 +12,9 @@
 
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/mv643xx_eth.h>
 #include <linux/gpio.h>
 #include "common.h"
 
-static struct mv643xx_eth_platform_data topkick_ge00_data = {
-	.phy_addr	= MV643XX_ETH_PHY_ADDR(0),
-};
-
 void __init usi_topkick_init(void)
 {
-	/*
-	 * Basic setup. Needs to be called early.
-	 */
-	kirkwood_ge00_init(&topkick_ge00_data);
 }
-- 
1.7.2.5
