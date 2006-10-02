From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH 2/2] remove Momentum Ocelot 3 andOcelot C network driver
 support
Date: Mon, 2 Oct 2006 23:34:42 +0900
Message-ID: <20061002233442.749b112a.yoichi_yuasa@tripeaks.co.jp>
References: <20061002233344.4e09116b.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo31.po.2iij.net ([210.128.50.54]:4380 "EHLO mo31.po.2iij.net")
	by vger.kernel.org with ESMTP id S932298AbWJBOgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 10:36:42 -0400
To: jgarzik@pobox.com
In-Reply-To: <20061002233344.4e09116b.yoichi_yuasa@tripeaks.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch has removed Momentum Ocelot 3 and Ocelot C network driver support.
It is listed in feature-removal-schedule.txt .

Yoichi

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/Kconfig generic/drivers/net/Kconfig
--- generic-orig/drivers/net/Kconfig	2006-10-01 14:27:17.837783500 +0900
+++ generic/drivers/net/Kconfig	2006-10-01 14:27:22.662085000 +0900
@@ -2292,7 +2292,7 @@ config UGETH_HAS_GIGA
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MV64360 || MOMENCO_OCELOT_3 || (PPC_MULTIPLATFORM && PPC32)
+	depends on MV64360 || (PPC_MULTIPLATFORM && PPC32)
 	select MII
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
