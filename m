From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [net-next PATCH 1/2] be2net: update some counters to display via
 ethtool
Date: Wed, 7 Dec 2011 17:44:13 -0600
Message-ID: <20111207234413.GA2344@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:28577 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757497Ab1LGXtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 18:49:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

update pmem_fifo_overflow_drop, rx_priority_pause_frames counters.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7236280..b29c447 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -316,6 +316,8 @@ static void populate_be3_stats(struct be_adapter *adapter)
 	struct be_drv_stats *drvs = &adapter->drv_stats;
 
 	be_dws_le_to_cpu(hw_stats, sizeof(*hw_stats));
+	drvs->pmem_fifo_overflow_drop = port_stats->pmem_fifo_overflow_drop;
+	drvs->rx_priority_pause_frames = port_stats->rx_priority_pause_frames;
 	drvs->rx_pause_frames = port_stats->rx_pause_frames;
 	drvs->rx_crc_errors = port_stats->rx_crc_errors;
 	drvs->rx_control_frames = port_stats->rx_control_frames;
-- 
1.7.5.4
