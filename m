From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: [[RESEND]PATCH v7 2/2] can: rcar_can: Move Renesas CAN driver to rcar dir
Date: Fri, 17 Jun 2016 09:20:56 +0100
Message-ID: <1466151656-51147-3-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
References: <1465888372-38319-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1466151656-51147-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Cc: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-renesas-soc@vger.kernel.org, horms@verge.net.au,
	magnus.damm@gmail.com, chris.paterson2@renesas.com,
	Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
To: davem@davemloft.net
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1466151656-51147-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch clubs the Renesas controller drivers in one rcar dir.

Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
---
 drivers/net/can/Kconfig               | 10 ----------
 drivers/net/can/Makefile              |  1 -
 drivers/net/can/rcar/Kconfig          | 10 ++++++++++
 drivers/net/can/rcar/Makefile         |  3 ++-
 drivers/net/can/{ => rcar}/rcar_can.c |  0
 5 files changed, 12 insertions(+), 12 deletions(-)
 rename drivers/net/can/{ => rcar}/rcar_can.c (100%)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index 13003a9..22570ea 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -104,16 +104,6 @@ config CAN_JANZ_ICAN3
 	  This driver can also be built as a module. If so, the module will be
 	  called janz-ican3.ko.
 
-config CAN_RCAR
-	tristate "Renesas R-Car CAN controller"
-	depends on ARCH_RENESAS || ARM
-	---help---
-	  Say Y here if you want to use CAN controller found on Renesas R-Car
-	  SoCs.
-
-	  To compile this driver as a module, choose M here: the module will
-	  be called rcar_can.
-
 config CAN_SUN4I
 	tristate "Allwinner A10 CAN controller"
 	depends on MACH_SUN4I || MACH_SUN7I || COMPILE_TEST
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 226d5b5..26ba4b7 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -25,7 +25,6 @@ obj-$(CONFIG_CAN_IFI_CANFD)	+= ifi_canfd/
 obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
 obj-$(CONFIG_CAN_MSCAN)		+= mscan/
 obj-$(CONFIG_CAN_M_CAN)		+= m_can/
-obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
 obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_SUN4I)		+= sun4i_can.o
 obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
diff --git a/drivers/net/can/rcar/Kconfig b/drivers/net/can/rcar/Kconfig
index 6ea64d1..7b03a3a 100644
--- a/drivers/net/can/rcar/Kconfig
+++ b/drivers/net/can/rcar/Kconfig
@@ -1,3 +1,13 @@
+config CAN_RCAR
+	tristate "Renesas R-Car CAN controller"
+	depends on ARCH_RENESAS || ARM
+	---help---
+	  Say Y here if you want to use CAN controller found on Renesas R-Car
+	  SoCs.
+
+	  To compile this driver as a module, choose M here: the module will
+	  be called rcar_can.
+
 config CAN_RCAR_CANFD
 	tristate "Renesas R-Car CAN FD controller"
 	depends on ARCH_RENESAS || ARM
diff --git a/drivers/net/can/rcar/Makefile b/drivers/net/can/rcar/Makefile
index cbaf498e..08de36a 100644
--- a/drivers/net/can/rcar/Makefile
+++ b/drivers/net/can/rcar/Makefile
@@ -1,5 +1,6 @@
 #
-#  Makefile for the Renesas R-Car CAN FD controller driver
+#  Makefile for the Renesas R-Car CAN & CAN FD controller drivers
 #
 
+obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
 obj-$(CONFIG_CAN_RCAR_CANFD)	+= rcar_canfd.o
diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar/rcar_can.c
similarity index 100%
rename from drivers/net/can/rcar_can.c
rename to drivers/net/can/rcar/rcar_can.c
-- 
1.9.1
