From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] igb_ptp: Include clocksource.h to get CLOCKSOURCE_MASK.
Date: Wed, 31 Dec 2014 18:33:59 -0500 (EST)
Message-ID: <20141231.183359.681102444156146233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbaLaXeA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 18:34:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 1d27f2d..8baf3fd 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -19,6 +19,7 @@
 #include <linux/device.h>
 #include <linux/pci.h>
 #include <linux/ptp_classify.h>
+#include <linux/clocksource.h>
 
 #include "igb.h"
 
-- 
2.1.0
