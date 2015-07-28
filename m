From: Lars Persson <lars.persson@axis.com>
Subject: [PATCH net-next 3/4] dwc_eth_qos: Add the synopsys folder to the build system.
Date: Tue, 28 Jul 2015 12:01:49 +0200
Message-ID: <1438077710-19175-4-git-send-email-larper@axis.com>
References: <1438077710-19175-1-git-send-email-larper@axis.com>
Cc: andire@axis.com, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, Lars Persson <larper@axis.com>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438077710-19175-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/Kconfig  | 1 +
 drivers/net/ethernet/Makefile | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f3bb178..05aa759 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -167,6 +167,7 @@ source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
+source "drivers/net/ethernet/synopsys/Kconfig"
 source "drivers/net/ethernet/tehuti/Kconfig"
 source "drivers/net/ethernet/ti/Kconfig"
 source "drivers/net/ethernet/tile/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c51014b..f42177b 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -77,6 +77,7 @@ obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_NET_VENDOR_SYNOPSYS) += synopsys/
 obj-$(CONFIG_NET_VENDOR_TEHUTI) += tehuti/
 obj-$(CONFIG_NET_VENDOR_TI) += ti/
 obj-$(CONFIG_TILE_NET) += tile/
-- 
2.1.4
