From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: [v11, 4/8] powerpc/fsl: move mpc85xx.h to include/linux/fsl
Date: Tue, 6 Sep 2016 16:28:19 +0800
Message-ID: <1473150503-9550-5-git-send-email-yangbo.lu@nxp.com>
References: <1473150503-9550-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>, Bhupesh
	Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	xiaobo.xie-3arQi8VN3Tc@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, leoyang.li-3arQi8VN3Tc@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>
To: <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood
	<oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1473150503-9550-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Move mpc85xx.h to include/linux/fsl and rename it to svr.h as a common
header file.  This SVR numberspace is used on some ARM chips as well as
PPC, and even to check for a PPC SVR multi-arch drivers would otherwise
need to ifdef the header inclusion and all references to the SVR symbols.

Signed-off-by: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Acked-by: Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>
Acked-by: Stephen Boyd <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Acked-by: Joerg Roedel <jroedel-l3A5Bk7waGM@public.gmane.org>
[scottwood: update description]
Signed-off-by: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
---
Changes for v2:
	- None
Changes for v3:
	- None
Changes for v4:
	- None
Changes for v5:
	- Changed to Move mpc85xx.h to include/linux/fsl/
	- Adjusted '#include <linux/fsl/svr.h>' position in file
Changes for v6:
	- None
Changes for v7:
	- Added 'Acked-by: Wolfram Sang' for I2C part
	- Also applied to arch/powerpc/kernel/cpu_setup_fsl_booke.S
Changes for v8:
	- Added 'Acked-by: Stephen Boyd' for clk part
	- Added 'Acked-by: Scott Wood'
	- Added 'Acked-by: Joerg Roedel' for iommu part
Changes for v9:
	- None
Changes for v10:
	- None
Changes for v11:
	- Updated description by Scott
---
 arch/powerpc/kernel/cpu_setup_fsl_booke.S                     | 2 +-
 arch/powerpc/sysdev/fsl_pci.c                                 | 2 +-
 drivers/clk/clk-qoriq.c                                       | 3 +--
 drivers/i2c/busses/i2c-mpc.c                                  | 2 +-
 drivers/iommu/fsl_pamu.c                                      | 3 +--
 drivers/net/ethernet/freescale/gianfar.c                      | 2 +-
 arch/powerpc/include/asm/mpc85xx.h => include/linux/fsl/svr.h | 4 ++--
 7 files changed, 8 insertions(+), 10 deletions(-)
 rename arch/powerpc/include/asm/mpc85xx.h => include/linux/fsl/svr.h (97%)

diff --git a/arch/powerpc/kernel/cpu_setup_fsl_booke.S b/arch/powerpc/kernel/cpu_setup_fsl_booke.S
index 462aed9..2b0284e 100644
--- a/arch/powerpc/kernel/cpu_setup_fsl_booke.S
+++ b/arch/powerpc/kernel/cpu_setup_fsl_booke.S
@@ -13,13 +13,13 @@
  *
  */
 
+#include <linux/fsl/svr.h>
 #include <asm/page.h>
 #include <asm/processor.h>
 #include <asm/cputable.h>
 #include <asm/ppc_asm.h>
 #include <asm/mmu-book3e.h>
 #include <asm/asm-offsets.h>
-#include <asm/mpc85xx.h>
 
 _GLOBAL(__e500_icache_setup)
 	mfspr	r0, SPRN_L1CSR1
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 0ef9df4..0fd1895 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -22,6 +22,7 @@
 #include <linux/delay.h>
 #include <linux/string.h>
 #include <linux/fsl/edac.h>
+#include <linux/fsl/svr.h>
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/memblock.h>
@@ -37,7 +38,6 @@
 #include <asm/pci-bridge.h>
 #include <asm/ppc-pci.h>
 #include <asm/machdep.h>
-#include <asm/mpc85xx.h>
 #include <asm/disassemble.h>
 #include <asm/ppc-opcode.h>
 #include <sysdev/fsl_soc.h>
diff --git a/drivers/clk/clk-qoriq.c b/drivers/clk/clk-qoriq.c
index 58566a17..4b6c438 100644
--- a/drivers/clk/clk-qoriq.c
+++ b/drivers/clk/clk-qoriq.c
@@ -13,6 +13,7 @@
 #include <linux/clk.h>
 #include <linux/clk-provider.h>
 #include <linux/fsl/guts.h>
+#include <linux/fsl/svr.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
@@ -1149,8 +1150,6 @@ bad_args:
 }
 
 #ifdef CONFIG_PPC
-#include <asm/mpc85xx.h>
-
 static const u32 a4510_svrs[] __initconst = {
 	(SVR_P2040 << 8) | 0x10,	/* P2040 1.0 */
 	(SVR_P2040 << 8) | 0x11,	/* P2040 1.1 */
diff --git a/drivers/i2c/busses/i2c-mpc.c b/drivers/i2c/busses/i2c-mpc.c
index 48ecffe..600704c 100644
--- a/drivers/i2c/busses/i2c-mpc.c
+++ b/drivers/i2c/busses/i2c-mpc.c
@@ -27,9 +27,9 @@
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
+#include <linux/fsl/svr.h>
 
 #include <asm/mpc52xx.h>
-#include <asm/mpc85xx.h>
 #include <sysdev/fsl_soc.h>
 
 #define DRV_NAME "mpc-i2c"
diff --git a/drivers/iommu/fsl_pamu.c b/drivers/iommu/fsl_pamu.c
index a34355f..af8fb27 100644
--- a/drivers/iommu/fsl_pamu.c
+++ b/drivers/iommu/fsl_pamu.c
@@ -21,11 +21,10 @@
 #include "fsl_pamu.h"
 
 #include <linux/fsl/guts.h>
+#include <linux/fsl/svr.h>
 #include <linux/interrupt.h>
 #include <linux/genalloc.h>
 
-#include <asm/mpc85xx.h>
-
 /* define indexes for each operation mapping scenario */
 #define OMI_QMAN        0x00
 #define OMI_FMAN        0x01
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index d20935d..b8dac84 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -86,11 +86,11 @@
 #include <linux/udp.h>
 #include <linux/in.h>
 #include <linux/net_tstamp.h>
+#include <linux/fsl/svr.h>
 
 #include <asm/io.h>
 #ifdef CONFIG_PPC
 #include <asm/reg.h>
-#include <asm/mpc85xx.h>
 #endif
 #include <asm/irq.h>
 #include <asm/uaccess.h>
diff --git a/arch/powerpc/include/asm/mpc85xx.h b/include/linux/fsl/svr.h
similarity index 97%
rename from arch/powerpc/include/asm/mpc85xx.h
rename to include/linux/fsl/svr.h
index 213f3a8..8d13836 100644
--- a/arch/powerpc/include/asm/mpc85xx.h
+++ b/include/linux/fsl/svr.h
@@ -9,8 +9,8 @@
  * (at your option) any later version.
  */
 
-#ifndef __ASM_PPC_MPC85XX_H
-#define __ASM_PPC_MPC85XX_H
+#ifndef FSL_SVR_H
+#define FSL_SVR_H
 
 #define SVR_REV(svr)	((svr) & 0xFF)		/* SOC design resision */
 #define SVR_MAJ(svr)	(((svr) >>  4) & 0xF)	/* Major revision field*/
-- 
2.1.0.27.g96db324
