From: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
Subject: [PATCH v7 2/3] can: Allwinner A10/A20 CAN Controller support - Defconfigs
Date: Tue, 15 Sep 2015 01:17:11 +0200
Message-ID: <1442272632-20251-3-git-send-email-info@gerhard-bertelsmann.de>
References: <1442272632-20251-1-git-send-email-info@gerhard-bertelsmann.de>
Cc: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: wg@grandegger.com, mkl@pengutronix.de,
	maxime.ripard@free-electrons.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442272632-20251-1-git-send-email-info@gerhard-bertelsmann.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Defconfigs for Allwinner A10/A20 CAN driver

Signed-off-by: Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
---

 arch/arm/configs/multi_v7_defconfig                |   1 +
 arch/arm/configs/sunxi_defconfig                   |   2 +
 2 files changed, 3 insertions(+)


diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 03deb7f..14eb6b9 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -153,6 +153,7 @@ CONFIG_CAN_DEV=y
 CONFIG_CAN_AT91=m
 CONFIG_CAN_XILINXCAN=y
 CONFIG_CAN_MCP251X=y
+CONFIG_CAN_SUN4I=y
 CONFIG_BT=m
 CONFIG_BT_MRVL=m
 CONFIG_BT_MRVL_SDIO=m
diff --git a/arch/arm/configs/sunxi_defconfig b/arch/arm/configs/sunxi_defconfig
index 51eea22..fe020a5 100644
--- a/arch/arm/configs/sunxi_defconfig
+++ b/arch/arm/configs/sunxi_defconfig
@@ -31,6 +31,8 @@ CONFIG_IP_PNP_BOOTP=y
 # CONFIG_INET_LRO is not set
 # CONFIG_INET_DIAG is not set
 # CONFIG_IPV6 is not set
+CONFIG_CAN=y
+CONFIG_CAN_SUN4I=y
 # CONFIG_WIRELESS is not set
 CONFIG_DEVTMPFS=y
 CONFIG_DEVTMPFS_MOUNT=y
