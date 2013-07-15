From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] bgmac: add dependency to phylib
Date: Mon, 15 Jul 2013 13:26:27 +0200
Message-ID: <1373887587-5182-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:55360 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755769Ab3GOL0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jul 2013 07:26:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bgmac is using functions from phylib, add the dependency.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 1d680ba..52c9603 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -131,6 +131,7 @@ config BNX2X_SRIOV
 config BGMAC
 	tristate "BCMA bus GBit core support"
 	depends on BCMA_HOST_SOC && HAS_DMA
+	select PHYLIB
 	---help---
 	  This driver supports GBit MAC and BCM4706 GBit MAC cores on BCMA bus.
 	  They can be found on BCM47xx SoCs and provide gigabit ethernet.
-- 
1.7.10.4
