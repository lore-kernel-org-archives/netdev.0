From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 4/5] net: sh_eth: add CONFIG_SH_ETH_NUM_RXDESC option
Date: Fri, 16 Mar 2012 17:46:16 +0900
Message-ID: <4F62FDD8.9010907@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows you to configure the number of RX descriptors.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/Kconfig  |    8 ++++++++
 drivers/net/ethernet/renesas/sh_eth.h |    2 +-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 9755b49..32c093b 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -17,3 +17,11 @@ config SH_ETH
 	  Renesas SuperH Ethernet device driver.
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
+
+config SH_ETH_NUM_RXDESC
+	int "Number of RX descriptor"
+	depends on SH_ETH
+	default "64"
+	---help---
+	  If you want to need more RX descriptors, you can configure
+	  the number of RX descriptors by this option.
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 9ab3f8b..667bdd2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -26,7 +26,7 @@
 #define CARDNAME	"sh-eth"
 #define TX_TIMEOUT	(5*HZ)
 #define TX_RING_SIZE	64	/* Tx ring size */
-#define RX_RING_SIZE	64	/* Rx ring size */
+#define RX_RING_SIZE	CONFIG_SH_ETH_NUM_RXDESC	/* Rx ring size */
 #define ETHERSMALL		60
 #define PKT_BUF_SZ		1538
 #define SH_ETH_TSU_TIMEOUT_MS	500
-- 
1.7.1
