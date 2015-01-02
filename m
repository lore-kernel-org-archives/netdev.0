From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 3/7] e1000e: convert to CYCLECOUNTER_MASK macro.
Date: Fri,  2 Jan 2015 20:22:05 +0100
Message-ID: <30d2bcf436a4b28f8c53f20ba5d6b35f1cddecc3.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:63977 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbbABTWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:18 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so6606499wgg.26
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:16 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2537d36a..332a298 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -43,7 +43,6 @@
 #include <linux/pm_runtime.h>
 #include <linux/aer.h>
 #include <linux/prefetch.h>
-#include <linux/clocksource.h>
 
 #include "e1000.h"
 
@@ -4190,7 +4189,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
 	/* Setup hardware time stamping cyclecounter */
 	if (adapter->flags & FLAG_HAS_HW_TIMESTAMP) {
 		adapter->cc.read = e1000e_cyclecounter_read;
-		adapter->cc.mask = CLOCKSOURCE_MASK(64);
+		adapter->cc.mask = CYCLECOUNTER_MASK(64);
 		adapter->cc.mult = 1;
 		/* cc.shift set in e1000e_get_base_tininca() */
 
-- 
1.7.10.4
