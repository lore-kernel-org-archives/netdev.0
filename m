From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH 1/2] net: fec: default select FEC_PTP at mx6 platform
Date: Wed, 7 Nov 2012 14:14:43 +0800
Message-ID: <1352268883-16800-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <richardcochran@gmail.com>,
	<shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.or>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:5179 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751053Ab2KGG5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 01:57:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove PPS.
Limit FEC_PTP option for i.MX chip only.
FEC_PTP default is on at mx6 platform.

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
index ff3be53..5ba6e1c 100644
--- a/drivers/net/ethernet/freescale/Kconfig
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -94,9 +94,9 @@ config GIANFAR
 
 config FEC_PTP
 	bool "PTP Hardware Clock (PHC)"
-	depends on FEC
-	select PPS
+	depends on FEC && ARCH_MXC
 	select PTP_1588_CLOCK
+	default y if SOC_IMX6Q
 	--help---
 	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
 	  driver.  Only the basic clock operations have been implemented.
-- 
1.7.1
