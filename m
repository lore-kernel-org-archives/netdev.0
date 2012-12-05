From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 6/8] bna: Add Stats Clear Counter
Date: Wed, 5 Dec 2012 15:01:08 -0800
Message-ID: <1354748470-26293-7-git-send-email-rmody@brocade.com>
References: <1354748470-26293-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:43486 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750803Ab2LEX17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 18:27:59 -0500
In-Reply-To: <1354748470-26293-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added Stats clear counter to the bfi_enet_stats_mac structure and ethtool stats
 
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfi_enet.h     |    1 +
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index eef6e1f..7d10e33 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -787,6 +787,7 @@ struct bfi_enet_stats_bpc {
 
 /* MAC Rx Statistics */
 struct bfi_enet_stats_mac {
+	u64 stats_clr_cnt;	/* times this stats cleared */
 	u64 frame_64;		/* both rx and tx counter */
 	u64 frame_65_127;		/* both rx and tx counter */
 	u64 frame_128_255;		/* both rx and tx counter */
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 40e1e84..455b5a2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -102,6 +102,7 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"rx_unmap_q_alloc_failed",
 	"rxbuf_alloc_failed",
 
+	"mac_stats_clr_cnt",
 	"mac_frame_64",
 	"mac_frame_65_127",
 	"mac_frame_128_255",
-- 
1.7.1
