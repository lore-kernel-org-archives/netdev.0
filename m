From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next] sh_eth, ravb: Use ARCH_RENESAS
Date: Wed,  2 Mar 2016 10:28:13 +0900
Message-ID: <1456882093-2603-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	linux-renesas-soc@vger.kernel.org,
	Simon Horman <horms+renesas@verge.net.au>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of ARCH_RENESAS in place of ARCH_SHMOBILE.

This is part of an ongoing process to migrate from ARCH_SHMOBILE to
ARCH_RENESAS the motivation for which being that RENESAS seems to be a more
appropriate name than SHMOBILE for the majority of Renesas ARM based SoCs.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 270c4c9cac7f..4f132cf177cd 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -18,7 +18,7 @@ if NET_VENDOR_RENESAS
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on HAS_DMA
-	depends on ARCH_SHMOBILE || SUPERH || COMPILE_TEST
+	depends on ARCH_RENESAS || SUPERH || COMPILE_TEST
 	select CRC32
 	select MII
 	select MDIO_BITBANG
@@ -32,7 +32,7 @@ config SH_ETH
 config RAVB
 	tristate "Renesas Ethernet AVB support"
 	depends on HAS_DMA
-	depends on ARCH_SHMOBILE || COMPILE_TEST
+	depends on ARCH_RENESAS || COMPILE_TEST
 	select CRC32
 	select MII
 	select MDIO_BITBANG
-- 
2.1.4
