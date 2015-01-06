From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] arm_arch_timer: include clocksource.h directly
Date: Tue,  6 Jan 2015 14:26:13 +0100
Message-ID: <1420550773-6752-1-git-send-email-richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:48286 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbAFN0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 08:26:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver makes use of the clocksource code. Previously it had only
included the proper header indirectly, but that chain was inadvertently
broken by 74d23cc "time: move the timecounter/cyclecounter code into its
own file."

This patch fixes the issue by including clocksource.h directly.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/clocksource/arm_arch_timer.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/clocksource/arm_arch_timer.c b/drivers/clocksource/arm_arch_timer.c
index 6a79fc4..8e67e72 100644
--- a/drivers/clocksource/arm_arch_timer.c
+++ b/drivers/clocksource/arm_arch_timer.c
@@ -15,6 +15,7 @@
 #include <linux/cpu.h>
 #include <linux/cpu_pm.h>
 #include <linux/clockchips.h>
+#include <linux/clocksource.h>
 #include <linux/interrupt.h>
 #include <linux/of_irq.h>
 #include <linux/of_address.h>
-- 
1.7.10.4
