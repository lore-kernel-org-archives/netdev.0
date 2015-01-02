From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 5/7] ixgbe: convert to CYCLECOUNTER_MASK macro.
Date: Fri,  2 Jan 2015 20:22:07 +0100
Message-ID: <67d136d2bf901d86fe716734eba7828895d7b254.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:50827 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbbABTWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:20 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so62427wid.3
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:19 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 47c29ea..79c00f5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -793,7 +793,7 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 
 	memset(&adapter->cc, 0, sizeof(adapter->cc));
 	adapter->cc.read = ixgbe_ptp_read;
-	adapter->cc.mask = CLOCKSOURCE_MASK(64);
+	adapter->cc.mask = CYCLECOUNTER_MASK(64);
 	adapter->cc.shift = shift;
 	adapter->cc.mult = 1;
 
-- 
1.7.10.4
