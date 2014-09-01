From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] net: sh_eth: fix driver dependencies
Date: Mon, 01 Sep 2014 15:15:37 +0200
Message-ID: <3693021.H9Y3NelqF1@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Cc: Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Renesas SuperH Ethernet support should be available only on
Renesas ARM SoCs and SuperH architecture.

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Simon Horman <horms@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>
---
 drivers/net/ethernet/renesas/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: b/drivers/net/ethernet/renesas/Kconfig
===================================================================
--- a/drivers/net/ethernet/renesas/Kconfig	2014-07-30 14:31:20.479522692 +0200
+++ b/drivers/net/ethernet/renesas/Kconfig	2014-09-01 14:45:36.160544016 +0200
@@ -5,6 +5,7 @@
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on HAS_DMA
+	depends on ARCH_SHMOBILE || ARCH_SH || COMPILE_TEST
 	select CRC32
 	select MII
 	select MDIO_BITBANG
