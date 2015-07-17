From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] siena: only report generic filters in get_ts_info
Date: Fri, 17 Jul 2015 07:25:16 -0700
Message-ID: <1437143123-5031-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42955 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757773AbbGQOZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
CC: Shradha Shah <sshah@solarflare.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/sfc/siena.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index b323b91..b2f886d 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -1042,9 +1042,5 @@ const struct efx_nic_type siena_a0_nic_type = {
 	.max_rx_ip_filters = FR_BZ_RX_FILTER_TBL0_ROWS,
 	.hwtstamp_filters = (1 << HWTSTAMP_FILTER_NONE |
 			     1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT |
-			     1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC |
-			     1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ |
-			     1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT |
-			     1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC |
-			     1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ),
+			     1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT),
 };
-- 
2.4.3
