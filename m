From: Richard Zhao <richard.zhao@linaro.org>
Subject: [PATCH V3 10/14] ARM: mxs: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 18:50:33 +0800
Message-ID: <1321008637-19999-11-git-send-email-richard.zhao@linaro.org>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux@arm.linux.org.uk>, <amit.kucheria@canonical.com>,
	<kernel@pengutronix.de>, <ben-linux@fluff.org>, <cjb@laptop.org>,
	<alan@linux.intel.com>, <eric.miao@linaro.org>,
	Richard Zhao <richard.zhao@linaro.org>
To: <linux-arm-kernel@lists.infradead.org>,
	<linux-i2c@vger.kernel.org>, <linux-mmc@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-serial@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:51823
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755534Ab1KKKvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 05:51:35 -0500
In-Reply-To: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Zhao <richard.zhao@linaro.org>
---
 arch/arm/mach-mxs/system.c |    2 +-
 arch/arm/mach-mxs/timer.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm/mach-mxs/system.c b/arch/arm/mach-mxs/system.c
index 20ec3bd..9760a12 100644
--- a/arch/arm/mach-mxs/system.c
+++ b/arch/arm/mach-mxs/system.c
@@ -66,7 +66,7 @@ static int __init mxs_arch_reset_init(void)
 
 	clk = clk_get_sys("rtc", NULL);
 	if (!IS_ERR(clk))
-		clk_enable(clk);
+		clk_prepare_enable(clk);
 
 	return 0;
 }
diff --git a/arch/arm/mach-mxs/timer.c b/arch/arm/mach-mxs/timer.c
index cace0d2..564a632 100644
--- a/arch/arm/mach-mxs/timer.c
+++ b/arch/arm/mach-mxs/timer.c
@@ -245,7 +245,7 @@ static int __init mxs_clocksource_init(struct clk *timer_clk)
 
 void __init mxs_timer_init(struct clk *timer_clk, int irq)
 {
-	clk_enable(timer_clk);
+	clk_prepare_enable(timer_clk);
 
 	/*
 	 * Initialize timers to a known state
-- 
1.7.5.4
