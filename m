From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 7/7] microblaze: include the new timecounter header.
Date: Thu,  1 Jan 2015 11:40:01 +0100
Message-ID: <9fbb44aff6275706b344b7873a002abaa4a71376.1420108214.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420108214.git.richardcochran@gmail.com>
References: <cover.1420108214.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The timecounter/cyclecounter code has moved, so users need the new include.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/microblaze/kernel/timer.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/microblaze/kernel/timer.c b/arch/microblaze/kernel/timer.c
index dd96f0e..c897745 100644
--- a/arch/microblaze/kernel/timer.c
+++ b/arch/microblaze/kernel/timer.c
@@ -17,6 +17,7 @@
 #include <linux/clockchips.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
+#include <linux/timecounter.h>
 #include <asm/cpuinfo.h>
 
 static void __iomem *timer_baseaddr;
-- 
1.7.10.4
