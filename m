From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v4 06/10] ARM: mx28: update clock and device name for dual fec support
Date: Thu, 6 Jan 2011 15:13:14 +0800
Message-ID: <1294297998-26930-7-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:58502
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754030Ab1AFHMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 02:12:03 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change device name from "fec" to "imx28-fec", so that fec driver
can distinguish mx28.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v4:
 - Use "imx28-fec" as fec device name

Changes for v3:
 - Change device name to "enet-mac"

 arch/arm/mach-mxs/clock-mx28.c           |    3 ++-
 arch/arm/mach-mxs/devices/platform-fec.c |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clock-mx28.c
index f20b254..e2a8b0f 100644
--- a/arch/arm/mach-mxs/clock-mx28.c
+++ b/arch/arm/mach-mxs/clock-mx28.c
@@ -606,7 +606,8 @@ static struct clk_lookup lookups[] = {
 	_REGISTER_CLOCK("duart", "apb_pclk", xbus_clk)
 	/* for amba-pl011 driver */
 	_REGISTER_CLOCK("duart", NULL, uart_clk)
-	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
+	_REGISTER_CLOCK("imx28-fec.0", NULL, fec_clk)
+	_REGISTER_CLOCK("imx28-fec.1", NULL, fec_clk)
 	_REGISTER_CLOCK("rtc", NULL, rtc_clk)
 	_REGISTER_CLOCK("pll2", NULL, pll2_clk)
 	_REGISTER_CLOCK(NULL, "hclk", hbus_clk)
diff --git a/arch/arm/mach-mxs/devices/platform-fec.c b/arch/arm/mach-mxs/devices/platform-fec.c
index c08168c..c42dff7 100644
--- a/arch/arm/mach-mxs/devices/platform-fec.c
+++ b/arch/arm/mach-mxs/devices/platform-fec.c
@@ -45,6 +45,6 @@ struct platform_device *__init mxs_add_fec(
 		},
 	};
 
-	return mxs_add_platform_device("fec", data->id,
+	return mxs_add_platform_device("imx28-fec", data->id,
 			res, ARRAY_SIZE(res), pdata, sizeof(*pdata));
 }
-- 
1.7.1


