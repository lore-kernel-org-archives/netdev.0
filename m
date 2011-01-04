From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v2 06/10] ARM: mx28: update clocks for dual fec support
Date: Tue, 4 Jan 2011 17:24:12 +0800
Message-ID: <1294133056-21195-7-git-send-email-shawn.guo@freescale.com>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:6595
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751875Ab1ADJXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 04:23:33 -0500
In-Reply-To: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register clocks fec.0 and fec.1 for dual fec support.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v2:
 - Rebase the patch against patch below which gets fundamental
   clocks explicitly called in clk_enable.
   [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
 - Register clocks fec.0 and fec.1 respectively than use wildcard
   NULL for both instances.

 arch/arm/mach-mxs/clock-mx28.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-mxs/clock-mx28.c b/arch/arm/mach-mxs/clock-mx28.c
index f20b254..f79587b 100644
--- a/arch/arm/mach-mxs/clock-mx28.c
+++ b/arch/arm/mach-mxs/clock-mx28.c
@@ -607,6 +607,7 @@ static struct clk_lookup lookups[] = {
 	/* for amba-pl011 driver */
 	_REGISTER_CLOCK("duart", NULL, uart_clk)
 	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
+	_REGISTER_CLOCK("fec.1", NULL, fec_clk)
 	_REGISTER_CLOCK("rtc", NULL, rtc_clk)
 	_REGISTER_CLOCK("pll2", NULL, pll2_clk)
 	_REGISTER_CLOCK(NULL, "hclk", hbus_clk)
-- 
1.7.1


