From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] dp83640: only report generic filters in ts_info
Date: Fri, 17 Jul 2015 07:25:17 -0700
Message-ID: <1437143123-5031-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19520 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757875AbbGQOZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

CC: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/phy/dp83640.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 00cb41e..185b03c 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -1449,17 +1449,9 @@ static int dp83640_ts_info(struct phy_device *dev, struct ethtool_ts_info *info)
 	info->rx_filters =
 		(1 << HWTSTAMP_FILTER_NONE) |
 		(1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
-		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
-		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
 		(1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
 		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
-		(1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ);
+		(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 	return 0;
 }
 
-- 
2.4.3
