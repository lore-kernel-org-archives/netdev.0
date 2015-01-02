From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 6/7] mlx4: include clocksource.h again
Date: Fri,  2 Jan 2015 20:22:08 +0100
Message-ID: <9251a397c8fd454ac92d46b9f3867815363085cb.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:36964 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbABTWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:21 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so6606560wgg.26
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:20 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver uses the function, clocksource_khz2mult, and so it really must
include clocksource.h.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_clock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index e9cce4f..90b5309 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/mlx4/device.h>
+#include <linux/clocksource.h>
 
 #include "mlx4_en.h"
 
-- 
1.7.10.4
