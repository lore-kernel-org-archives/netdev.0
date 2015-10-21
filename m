From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/8] cxgb4: Align ethtool get stat settings
Date: Wed, 21 Oct 2015 14:39:50 +0530
Message-ID: <1445418597-771-2-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:30345 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754122AbbJUJKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:06 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Align the ethtool get stats settings with the rest so it looks uniform

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 146 ++++++++++-----------
 1 file changed, 73 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 02e4e02..1127642 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -35,79 +35,79 @@ static void set_msglevel(struct net_device *dev, u32 val)
 }
 
 static const char stats_strings[][ETH_GSTRING_LEN] = {
-	"TxOctetsOK         ",
-	"TxFramesOK         ",
-	"TxBroadcastFrames  ",
-	"TxMulticastFrames  ",
-	"TxUnicastFrames    ",
-	"TxErrorFrames      ",
-
-	"TxFrames64         ",
-	"TxFrames65To127    ",
-	"TxFrames128To255   ",
-	"TxFrames256To511   ",
-	"TxFrames512To1023  ",
-	"TxFrames1024To1518 ",
-	"TxFrames1519ToMax  ",
-
-	"TxFramesDropped    ",
-	"TxPauseFrames      ",
-	"TxPPP0Frames       ",
-	"TxPPP1Frames       ",
-	"TxPPP2Frames       ",
-	"TxPPP3Frames       ",
-	"TxPPP4Frames       ",
-	"TxPPP5Frames       ",
-	"TxPPP6Frames       ",
-	"TxPPP7Frames       ",
-
-	"RxOctetsOK         ",
-	"RxFramesOK         ",
-	"RxBroadcastFrames  ",
-	"RxMulticastFrames  ",
-	"RxUnicastFrames    ",
-
-	"RxFramesTooLong    ",
-	"RxJabberErrors     ",
-	"RxFCSErrors        ",
-	"RxLengthErrors     ",
-	"RxSymbolErrors     ",
-	"RxRuntFrames       ",
-
-	"RxFrames64         ",
-	"RxFrames65To127    ",
-	"RxFrames128To255   ",
-	"RxFrames256To511   ",
-	"RxFrames512To1023  ",
-	"RxFrames1024To1518 ",
-	"RxFrames1519ToMax  ",
-
-	"RxPauseFrames      ",
-	"RxPPP0Frames       ",
-	"RxPPP1Frames       ",
-	"RxPPP2Frames       ",
-	"RxPPP3Frames       ",
-	"RxPPP4Frames       ",
-	"RxPPP5Frames       ",
-	"RxPPP6Frames       ",
-	"RxPPP7Frames       ",
-
-	"RxBG0FramesDropped ",
-	"RxBG1FramesDropped ",
-	"RxBG2FramesDropped ",
-	"RxBG3FramesDropped ",
-	"RxBG0FramesTrunc   ",
-	"RxBG1FramesTrunc   ",
-	"RxBG2FramesTrunc   ",
-	"RxBG3FramesTrunc   ",
-
-	"TSO                ",
-	"TxCsumOffload      ",
-	"RxCsumGood         ",
-	"VLANextractions    ",
-	"VLANinsertions     ",
-	"GROpackets         ",
-	"GROmerged          ",
+	"tx_octets_ok		",
+	"tx_frames_ok		",
+	"tx_broadcast_frames	",
+	"tx_multicast_frames	",
+	"tx_unicast_frames	",
+	"tx_error_frames	",
+
+	"tx_frames_64		",
+	"tx_frames_65_to_127	",
+	"tx_frames_128_to_255	",
+	"tx_frames_256_to_511	",
+	"tx_frames_512_to_1023	",
+	"tx_frames_1024_to_1518	",
+	"tx_frames_1519_to_max	",
+
+	"tx_frames_dropped	",
+	"tx_pause_frames	",
+	"tx_ppp0_frames		",
+	"tx_ppp1_frames		",
+	"tx_ppp2_frames		",
+	"tx_ppp3_frames		",
+	"tx_ppp4_frames		",
+	"tx_ppp5_frames		",
+	"tx_ppp6_frames		",
+	"tx_ppp7_frames		",
+
+	"rx_octets_ok		",
+	"rx_frames_ok		",
+	"rx_broadcast_frames	",
+	"rx_multicast_frames	",
+	"rx_unicast_frames	",
+
+	"rx_frames_too_long	",
+	"rx_jabber_errors	",
+	"rx_fcs_errors		",
+	"rx_length_errors	",
+	"rx_symbol_errors	",
+	"rx_runt_frames		",
+
+	"rx_frames_64		",
+	"rx_frames_65_to_127	",
+	"rx_frames_128_to_255	",
+	"rx_frames_256_to_511	",
+	"rx_frames_512_to_1023	",
+	"rx_frames_1024_to_1518	",
+	"rx_frames_1519_to_max	",
+
+	"rx_pause_frames	",
+	"rx_ppp0_frames		",
+	"rx_ppp1_frames		",
+	"rx_ppp2_frames		",
+	"rx_ppp3_frames		",
+	"rx_ppp4_frames		",
+	"rx_ppp5_frames		",
+	"rx_ppp6_frames		",
+	"rx_ppp7_frames		",
+
+	"rx_bg0_frames_dropped	",
+	"rx_bg1_frames_dropped	",
+	"rx_bg2_frames_dropped	",
+	"rx_bg3_frames_dropped	",
+	"rx_bg0_frames_trunc	",
+	"rx_bg1_frames_trunc	",
+	"rx_bg2_frames_trunc	",
+	"rx_bg3_frames_trunc	",
+
+	"tso			",
+	"tx_csum_offload	",
+	"rx_csum_good		",
+	"vlan_extractions	",
+	"vlan_insertions	",
+	"gro_packets		",
+	"gro_merged		",
 };
 
 static char adapter_stats_strings[][ETH_GSTRING_LEN] = {
-- 
2.3.4
