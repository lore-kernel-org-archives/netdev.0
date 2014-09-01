From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH] net: calxedaxgmac: fix driver dependencies
Date: Mon, 01 Sep 2014 17:39:04 +0200
Message-ID: <7268934.nBXHizFkl4@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
Cc: Rob Herring <robh@kernel.org>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:24571 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbaIAPjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 11:39:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calxeda 1G/10G XGMAC Ethernet support should be available only on
Calxeda ECX-1000/2000 (Highbank/Midway) platforms.

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Rob Herring <robh@kernel.org>
---
 drivers/net/ethernet/calxeda/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: b/drivers/net/ethernet/calxeda/Kconfig
===================================================================
--- a/drivers/net/ethernet/calxeda/Kconfig	2014-07-30 14:31:12.159522474 +0200
+++ b/drivers/net/ethernet/calxeda/Kconfig	2014-09-01 17:33:49.232810483 +0200
@@ -1,6 +1,7 @@
 config NET_CALXEDA_XGMAC
 	tristate "Calxeda 1G/10G XGMAC Ethernet driver"
 	depends on HAS_IOMEM && HAS_DMA
+	depends on ARCH_HIGHBANK || COMPILE_TEST
 	select CRC32
 	help
 	  This is the driver for the XGMAC Ethernet IP block found on Calxeda
