From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/16] batman-adv: add kerneldoc for batadv_iv_ogm_aggr_packet
Date: Wed,  3 Feb 2016 10:18:34 +0800
Message-ID: <1454465917-13332-14-git-send-email-a__6216.38462548635$1454467248$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:39559 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcBCCki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:38 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bat_iv_ogm.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a6d389b0563c..7377313d3e42 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -396,7 +396,14 @@ static u8 batadv_hop_penalty(u8 tq, const struct batadv_priv *bat_priv)
 	return new_tq;
 }
 
-/* is there another aggregated packet here? */
+/**
+ * batadv_iv_ogm_aggr_packet - checks if there is another OGM attached
+ * @buff_pos: current position in the skb
+ * @packet_len: total length of the skb
+ * @tvlv_len: tvlv length of the previously considered OGM
+ *
+ * Return: true if there is enough space for another OGM, false otherwise.
+ */
 static bool batadv_iv_ogm_aggr_packet(int buff_pos, int packet_len,
 				      __be16 tvlv_len)
 {
-- 
2.7.0
