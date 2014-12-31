From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] e1000e: Include clocksource.h to get CLOCKSOURCE_MASK.
Date: Wed, 31 Dec 2014 18:33:47 -0500 (EST)
Message-ID: <20141231.183347.862533634176009078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbaLaXdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:33:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index e14fd85..2537d36a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -43,6 +43,7 @@
 #include <linux/pm_runtime.h>
 #include <linux/aer.h>
 #include <linux/prefetch.h>
+#include <linux/clocksource.h>
 
 #include "e1000.h"
 
-- 
2.1.0
