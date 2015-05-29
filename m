From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 09/16] batman-adv: iv_ogm_aggr_packet, bool return value
Date: Fri, 29 May 2015 11:05:21 +0200
Message-ID: <1432890328-8247-10-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:5617 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755971AbbE2Jcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:32:45 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

This function returns bool values, so it should be defined to return
them instead of the whole int range.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bat_iv_ogm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 123aabb..0015138 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -392,8 +392,8 @@ static uint8_t batadv_hop_penalty(uint8_t tq,
 }
 
 /* is there another aggregated packet here? */
-static int batadv_iv_ogm_aggr_packet(int buff_pos, int packet_len,
-				     __be16 tvlv_len)
+static bool batadv_iv_ogm_aggr_packet(int buff_pos, int packet_len,
+				      __be16 tvlv_len)
 {
 	int next_buff_pos = 0;
 
-- 
2.4.2
