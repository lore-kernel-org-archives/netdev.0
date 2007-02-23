From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: more stats
Date: Fri, 23 Feb 2007 15:10:46 -0800
Message-ID: <20070223231353.539384000@linux-foundation.org>
References: <20070223231042.860031000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40981 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933273AbXBWXRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 18:17:35 -0500
Content-Disposition: inline; filename=sky2-stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a simple enhancement to dump more device statistics with ethtool.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

--- linux-2.6.16.y.orig/drivers/net/sky2.c	2007-02-23 14:45:36.000000000 -0800
+++ linux-2.6.16.y/drivers/net/sky2.c	2007-02-23 14:45:39.000000000 -0800
@@ -2542,17 +2542,34 @@
 	{ "rx_unicast",    GM_RXF_UC_OK },
 	{ "tx_mac_pause",  GM_TXF_MPAUSE },
 	{ "rx_mac_pause",  GM_RXF_MPAUSE },
-	{ "collisions",    GM_TXF_SNG_COL },
+	{ "collisions",    GM_TXF_COL },
 	{ "late_collision",GM_TXF_LAT_COL },
 	{ "aborted", 	   GM_TXF_ABO_COL },
+	{ "single_collisions", GM_TXF_SNG_COL },
 	{ "multi_collisions", GM_TXF_MUL_COL },
-	{ "fifo_underrun", GM_TXE_FIFO_UR },
-	{ "fifo_overflow", GM_RXE_FIFO_OV },
-	{ "rx_toolong",    GM_RXF_LNG_ERR },
-	{ "rx_jabber",     GM_RXF_JAB_PKT },
+
+	{ "rx_short",      GM_RXF_SHT },
 	{ "rx_runt", 	   GM_RXE_FRAG },
+	{ "rx_64_byte_packets", GM_RXF_64B },
+	{ "rx_65_to_127_byte_packets", GM_RXF_127B },
+	{ "rx_128_to_255_byte_packets", GM_RXF_255B },
+	{ "rx_256_to_511_byte_packets", GM_RXF_511B },
+	{ "rx_512_to_1023_byte_packets", GM_RXF_1023B },
+	{ "rx_1024_to_1518_byte_packets", GM_RXF_1518B },
+	{ "rx_1518_to_max_byte_packets", GM_RXF_MAX_SZ },
 	{ "rx_too_long",   GM_RXF_LNG_ERR },
+	{ "rx_fifo_overflow", GM_RXE_FIFO_OV },
+	{ "rx_jabber",     GM_RXF_JAB_PKT },
 	{ "rx_fcs_error",   GM_RXF_FCS_ERR },
+
+	{ "tx_64_byte_packets", GM_TXF_64B },
+	{ "tx_65_to_127_byte_packets", GM_TXF_127B },
+	{ "tx_128_to_255_byte_packets", GM_TXF_255B },
+	{ "tx_256_to_511_byte_packets", GM_TXF_511B },
+	{ "tx_512_to_1023_byte_packets", GM_TXF_1023B },
+	{ "tx_1024_to_1518_byte_packets", GM_TXF_1518B },
+	{ "tx_1519_to_max_byte_packets", GM_TXF_MAX_SZ },
+	{ "tx_fifo_underrun", GM_TXE_FIFO_UR },
 };
 
 static u32 sky2_get_rx_csum(struct net_device *dev)

--
Stephen Hemminger <shemminger@linux-foundation.org>

