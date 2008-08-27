From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] netdev: Blackfin EMAC Driver: the BF526 also supports the MAC, so updates things accordingly
Date: Wed, 27 Aug 2008 11:47:57 +0800
Message-ID: <1219808877-15168-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:39128 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbYH0Drv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 23:47:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>

Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a5c141c..4a11296 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -822,14 +822,14 @@ config ULTRA32
 	  will be called smc-ultra32.
 
 config BFIN_MAC
-	tristate "Blackfin 527/536/537 on-chip mac support"
-	depends on NET_ETHERNET && (BF527 || BF537 || BF536)
+	tristate "Blackfin on-chip MAC support"
+	depends on NET_ETHERNET && (BF526 || BF527 || BF536 || BF537)
 	select CRC32
 	select MII
 	select PHYLIB
 	select BFIN_MAC_USE_L1 if DMA_UNCACHED_NONE
 	help
-	  This is the driver for blackfin on-chip mac device. Say Y if you want it
+	  This is the driver for Blackfin on-chip mac device. Say Y if you want it
 	  compiled into the kernel. This driver is also available as a module
 	  ( = code which can be inserted in and removed from the running kernel
 	  whenever you want). The module will be called bfin_mac.
-- 
1.5.6
