From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: only report generic filters in get_ts_info
Date: Fri, 17 Jul 2015 07:25:13 -0700
Message-ID: <1437143123-5031-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757899AbbGQOZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 0b68f61..f2075d5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1467,17 +1467,8 @@ static int i40e_get_ts_info(struct net_device *dev,
 	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
 
 	info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
-			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
-			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
-			   (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
+			   (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			   (1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 
 	return 0;
 }
-- 
2.4.3
