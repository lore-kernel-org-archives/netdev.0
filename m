From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 06/10] ARM: mx28: update clock and device name for dual fec support
Date: Wed, 5 Jan 2011 22:07:33 +0800
Message-ID: <1294236457-17476-7-git-send-email-shawn.guo@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:36440 "EHLO
	TX2EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab1AEOG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:06:28 -0500
In-Reply-To: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change device name from "fec" to "enet-mac", so that fec driver
can distinguish ENET-MAC controller from FEC.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v3:
 - Change device name to "enet-mac"

 arch/arm/mach-mxs/clock-mx28.c           |    3 ++-
 arch/arm/mach-mxs/devices/platform-fec.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clock-mx28.c
index f20b254..933d3e6 100644
--- a/arch/arm/mach-mxs/clock-mx28.c
+++ b/arch/arm/mach-mxs/clock-mx28.c
@@ -606,7 +606,8 @@ static struct clk_lookup lookups[] = {
 	_REGISTER_CLOCK("duart", "apb_pclk", xbus_clk)
 	/* for amba-pl011 driver */
 	_REGISTER_CLOCK("duart", NULL, uart_clk)
-	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
+	_REGISTER_CLOCK("enet-mac.0", NULL, fec_clk)
+	_REGISTER_CLOCK("enet-mac.1", NULL, fec_clk)
 	_REGISTER_CLOCK("rtc", NULL, rtc_clk)
 	_REGISTER_CLOCK("pll2", NULL, pll2_clk)
 	_REGISTER_CLOCK(NULL, "hclk", hbus_clk)
diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/mach-mxs/devices/platform-fec.c
index c08168c..754bd83 100644
--- a/arch/arm/mach-mxs/devices/platform-fec.c
+++ b/arch/arm/mach-mxs/devices/platform-fec.c
@@ -45,6 +45,6 @@ struct platform_device *__init mxs_add_fec(
 		},
 	};
 
-	return mxs_add_platform_device("fec", data->id,
+	return mxs_add_platform_device("enet-mac", data->id,
 			res, ARRAY_SIZE(res), pdata, sizeof(*pdata));
 }
-- 
1.7.1


