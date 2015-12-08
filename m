From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/7] cxgb4: Align rest of the ethtool get stats
Date: Tue,  8 Dec 2015 10:09:11 +0530
Message-ID: <1449549557-16023-2-git-send-email-hariprasad@chelsio.com>
References: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:6162 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753363AbbLHEiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 23:38:15 -0500
In-Reply-To: <1449549557-16023-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 146 ++++++++++-----------
 1 file changed, 73 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index a077f94..2a61a42 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -35,79 +35,79 @@ static void set_msglevel(struct net_device *dev, u32 val)
 }
 
 static const char stats_strings[][ETH_GSTRING_LEN] = {
-	"tx_octets_ok		",
-	"tx_frames_ok		",
-	"tx_broadcast_frames	",
-	"tx_multicast_frames	",
-	"tx_unicast_frames	",
-	"tx_error_frames	",
-
-	"tx_frames_64		",
-	"tx_frames_65_to_127	",
-	"tx_frames_128_to_255	",
-	"tx_frames_256_to_511	",
-	"tx_frames_512_to_1023	",
-	"tx_frames_1024_to_1518	",
-	"tx_frames_1519_to_max	",
-
-	"tx_frames_dropped	",
-	"tx_pause_frames	",
-	"tx_ppp0_frames		",
-	"tx_ppp1_frames		",
-	"tx_ppp2_frames		",
-	"tx_ppp3_frames		",
-	"tx_ppp4_frames		",
-	"tx_ppp5_frames		",
-	"tx_ppp6_frames		",
-	"tx_ppp7_frames		",
-
-	"rx_octets_ok		",
-	"rx_frames_ok		",
-	"rx_broadcast_frames	",
-	"rx_multicast_frames	",
-	"rx_unicast_frames	",
-
-	"rx_frames_too_long	",
-	"rx_jabber_errors	",
-	"rx_fcs_errors		",
-	"rx_length_errors	",
-	"rx_symbol_errors	",
-	"rx_runt_frames		",
-
-	"rx_frames_64		",
-	"rx_frames_65_to_127	",
-	"rx_frames_128_to_255	",
-	"rx_frames_256_to_511	",
-	"rx_frames_512_to_1023	",
-	"rx_frames_1024_to_1518	",
-	"rx_frames_1519_to_max	",
-
-	"rx_pause_frames	",
-	"rx_ppp0_frames		",
-	"rx_ppp1_frames		",
-	"rx_ppp2_frames		",
-	"rx_ppp3_frames		",
-	"rx_ppp4_frames		",
-	"rx_ppp5_frames		",
-	"rx_ppp6_frames		",
-	"rx_ppp7_frames		",
-
-	"rx_bg0_frames_dropped	",
-	"rx_bg1_frames_dropped	",
-	"rx_bg2_frames_dropped	",
-	"rx_bg3_frames_dropped	",
-	"rx_bg0_frames_trunc	",
-	"rx_bg1_frames_trunc	",
-	"rx_bg2_frames_trunc	",
-	"rx_bg3_frames_trunc	",
-
-	"tso			",
-	"tx_csum_offload	",
-	"rx_csum_good		",
-	"vlan_extractions	",
-	"vlan_insertions	",
-	"gro_packets		",
-	"gro_merged		",
+	"tx_octets_ok           ",
+	"tx_frames_ok           ",
+	"tx_broadcast_frames    ",
+	"tx_multicast_frames    ",
+	"tx_unicast_frames      ",
+	"tx_error_frames        ",
+
+	"tx_frames_64           ",
+	"tx_frames_65_to_127    ",
+	"tx_frames_128_to_255   ",
+	"tx_frames_256_to_511   ",
+	"tx_frames_512_to_1023  ",
+	"tx_frames_1024_to_1518 ",
+	"tx_frames_1519_to_max  ",
+
+	"tx_frames_dropped      ",
+	"tx_pause_frames        ",
+	"tx_ppp0_frames         ",
+	"tx_ppp1_frames         ",
+	"tx_ppp2_frames         ",
+	"tx_ppp3_frames         ",
+	"tx_ppp4_frames         ",
+	"tx_ppp5_frames         ",
+	"tx_ppp6_frames         ",
+	"tx_ppp7_frames         ",
+
+	"rx_octets_ok           ",
+	"rx_frames_ok           ",
+	"rx_broadcast_frames    ",
+	"rx_multicast_frames    ",
+	"rx_unicast_frames      ",
+
+	"rx_frames_too_long     ",
+	"rx_jabber_errors       ",
+	"rx_fcs_errors          ",
+	"rx_length_errors       ",
+	"rx_symbol_errors       ",
+	"rx_runt_frames         ",
+
+	"rx_frames_64           ",
+	"rx_frames_65_to_127    ",
+	"rx_frames_128_to_255   ",
+	"rx_frames_256_to_511   ",
+	"rx_frames_512_to_1023  ",
+	"rx_frames_1024_to_1518 ",
+	"rx_frames_1519_to_max  ",
+
+	"rx_pause_frames        ",
+	"rx_ppp0_frames         ",
+	"rx_ppp1_frames         ",
+	"rx_ppp2_frames         ",
+	"rx_ppp3_frames         ",
+	"rx_ppp4_frames         ",
+	"rx_ppp5_frames         ",
+	"rx_ppp6_frames         ",
+	"rx_ppp7_frames         ",
+
+	"rx_bg0_frames_dropped  ",
+	"rx_bg1_frames_dropped  ",
+	"rx_bg2_frames_dropped  ",
+	"rx_bg3_frames_dropped  ",
+	"rx_bg0_frames_trunc    ",
+	"rx_bg1_frames_trunc    ",
+	"rx_bg2_frames_trunc    ",
+	"rx_bg3_frames_trunc    ",
+
+	"tso                    ",
+	"tx_csum_offload        ",
+	"rx_csum_good           ",
+	"vlan_extractions       ",
+	"vlan_insertions        ",
+	"gro_packets            ",
+	"gro_merged             ",
 };
 
 static char adapter_stats_strings[][ETH_GSTRING_LEN] = {
-- 
2.3.4
