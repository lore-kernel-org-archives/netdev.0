From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/6] [RFC] qlge: New Driver: Makefile and Kconfig changes.
Date: Fri, 22 Aug 2008 13:21:01 -0700
Message-ID: <12194364661612-git-send-email-ron.mercer@qlogic.com>
References: <20080822200906.GD2551@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, Ron Mercer <ron.mercer@qlogic.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39657 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbYHVUVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:21:40 -0400
In-Reply-To: <20080822200906.GD2551@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/Kconfig  |    9 +++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fa533c2..0781544 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2495,6 +2495,15 @@ config BNX2X
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2x.  This is recommended.
 
+config QLGE
+	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
+	depends on PCI
+	help
+	  This driver supports QLogic ISP8XXX 10Gb Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called qlge.
+
 source "drivers/net/sfc/Kconfig"
 
 endif # NETDEV_10000
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 7629c90..f5f3b16 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -128,6 +128,7 @@ obj-$(CONFIG_AX88796) += ax88796.o
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 obj-$(CONFIG_QLA3XXX) += qla3xxx.o
+obj-$(CONFIG_QLGE) += qlge/
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
-- 
1.5.0.rc4.16.g9e258

