From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 7/7] microblaze: include the new timecounter header.
Date: Fri,  2 Jan 2015 20:22:09 +0100
Message-ID: <6b9eb38f620943c83e6254c8b67f99957fecd5ff.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:55934 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbbABTWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:23 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so4816807wes.24
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:22 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
