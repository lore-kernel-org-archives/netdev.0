From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 4/7] igb: convert to CYCLECOUNTER_MASK macro.
Date: Fri,  2 Jan 2015 20:22:06 +0100
Message-ID: <c2295ceb5da5fc1dfc5a5e8567f0a37b353c0333.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:47804 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbbABTWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:19 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so4794995wes.6
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:18 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 8baf3fd..5e7a4e3 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -19,7 +19,6 @@
 #include <linux/device.h>
 #include <linux/pci.h>
 #include <linux/ptp_classify.h>
-#include <linux/clocksource.h>
 
 #include "igb.h"
 
@@ -766,7 +765,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82576;
-		adapter->cc.mask = CLOCKSOURCE_MASK(64);
+		adapter->cc.mask = CYCLECOUNTER_MASK(64);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = IGB_82576_TSYNC_SHIFT;
 		/* Dial the nominal frequency. */
@@ -786,7 +785,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.settime = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82580;
-		adapter->cc.mask = CLOCKSOURCE_MASK(IGB_NBITS_82580);
+		adapter->cc.mask = CYCLECOUNTER_MASK(IGB_NBITS_82580);
 		adapter->cc.mult = 1;
 		adapter->cc.shift = 0;
 		/* Enable the timer functions by clearing bit 31. */
-- 
1.7.10.4
