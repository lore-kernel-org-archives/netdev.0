From: "Barak Witkowski" <barak@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2x: fix typo in fcoe stats collection
Date: Wed, 7 Dec 2011 15:45:36 +0200
Message-ID: <1323265536-9760-2-git-send-email-barak@broadcom.com>
References: <Barak Witkowski <barak@broadcom.com>
 <1323265536-9760-1-git-send-email-barak@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Barak Witkowski" <barak@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3847 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab1LGNqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 08:46:03 -0500
In-Reply-To: <1323265536-9760-1-git-send-email-barak@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d104695..12b8001 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2994,7 +2994,7 @@ static void bnx2x_drv_info_fcoe_stat(struct bnx2x *bp)
 		       fcoe_q_tstorm_stats->rcv_bcast_pkts);
 
 		ADD_64(fcoe_stat->rx_frames_hi, 0, fcoe_stat->rx_frames_lo,
-		       fcoe_q_tstorm_stats->rcv_ucast_pkts);
+		       fcoe_q_tstorm_stats->rcv_mcast_pkts);
 
 		ADD_64(fcoe_stat->tx_bytes_hi, 0, fcoe_stat->tx_bytes_lo,
 		       fw_fcoe_stat->tx_stat.fcoe_tx_byte_cnt);
-- 
1.7.7.4
