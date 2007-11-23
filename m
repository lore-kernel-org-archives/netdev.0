From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 1/2] Blackfin SMC91x Driver: punt CONFIG_BFIN -- we already have CONFIG_BLACKFIN
Date: Fri, 23 Nov 2007 17:55:50 +0800
Message-ID: <1195811751-25319-2-git-send-email-bryan.wu@analog.com>
References: <1195811751-25319-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	Mike Frysinger <michael.frysinger@analog.com>,
	Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:42121 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbXKWJz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 04:55:59 -0500
In-Reply-To: <1195811751-25319-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <michael.frysinger@analog.com>

Signed-off-by: Mike Frysinger <michael.frysinger@analog.com>
Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/Kconfig  |    2 +-
 drivers/net/smc91x.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e8d69b0..1437b37 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -888,7 +888,7 @@ config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BFIN
+	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || SOC_AU1X00 || BLACKFIN
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index db34e1e..07b7f71 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -55,7 +55,7 @@
 #define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
 
-#elif defined(CONFIG_BFIN)
+#elif defined(CONFIG_BLACKFIN)
 
 #define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
 #define RPC_LSA_DEFAULT		RPC_LED_100_10
-- 
1.5.3.4
