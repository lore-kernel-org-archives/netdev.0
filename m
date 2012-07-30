From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/2] drivers: net: ethernet: cpsw: Add SOC dependency support for cpsw dependent modules
Date: Tue, 31 Jul 2012 01:47:13 +0530
Message-ID: <1343679434-2369-2-git-send-email-mugunthanvnm@ti.com>
References: <1343679434-2369-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:58458 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516Ab2G3UR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 16:17:27 -0400
In-Reply-To: <1343679434-2369-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpsw is dependent on davinci_cpdma and davinci_mdio, so adding SOC support for
dependent modules

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index 1b173a6..b26cbda 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -32,7 +32,7 @@ config TI_DAVINCI_EMAC
 
 config TI_DAVINCI_MDIO
 	tristate "TI DaVinci MDIO Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
 	select PHYLIB
 	---help---
 	  This driver supports TI's DaVinci MDIO module.
@@ -42,7 +42,7 @@ config TI_DAVINCI_MDIO
 
 config TI_DAVINCI_CPDMA
 	tristate "TI DaVinci CPDMA Support"
-	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
+	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX )
 	---help---
 	  This driver supports TI's DaVinci CPDMA dma engine.
 
-- 
1.7.0.4
