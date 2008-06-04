From: "Yusuke.Goda" <goda.yusuke@renesas.com>
Subject: smc911x: Add AP325RXA board support
Date: Wed, 04 Jun 2008 19:54:03 +0900
Message-ID: <4846744B.4000407@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds AP325RXA board support to scc911x driver.

Signed-off-by: Yusuke Goda <goda.yusuke@renesas.com>
---
 drivers/net/Kconfig   |    2 +-
 drivers/net/smc911x.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd0ec9e..b618d8e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -955,7 +955,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || SH_MAGIC_PANEL_R2 || SH_AP325RXA
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 7defa63..d45be9c 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -37,7 +37,7 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
-#elif defined(CONFIG_SH_MAGIC_PANEL_R2)
+#elif defined(CONFIG_SH_MAGIC_PANEL_R2) || defined(CONFIG_SH_AP325RXA)
   #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
-- 
1.5.4.5

