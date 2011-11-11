From: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH V3 02/14] ARM: mxc: time: add clk_prepare/clk_unprepare
Date: Fri, 11 Nov 2011 18:50:25 +0800
Message-ID: <1321008637-19999-3-git-send-email-richard.zhao@linaro.org>
References: <1321008637-19999-1-git-send-email-richard.zhao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <amit.kucheria-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	<kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>, <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	<alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, <eric.miao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1321008637-19999-1-git-send-email-richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Zhao <richard.zhao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 arch/arm/plat-mxc/time.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/arm/plat-mxc/time.c b/arch/arm/plat-mxc/time.c
index 4b0fe28..b4e8b18 100644
--- a/arch/arm/plat-mxc/time.c
+++ b/arch/arm/plat-mxc/time.c
@@ -292,7 +292,7 @@ void __init mxc_timer_init(struct clk *timer_clk, void __iomem *base, int irq)
 {
 	uint32_t tctl_val;
 
-	clk_enable(timer_clk);
+	clk_prepare_enable(timer_clk);
 
 	timer_base = base;
 
-- 
1.7.5.4
