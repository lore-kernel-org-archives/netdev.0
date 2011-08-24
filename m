From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 7/8] batman-adv: reuse tt_len() to calculate tt buffer length
Date: Wed, 24 Aug 2011 15:00:37 +0200
Message-ID: <1314190838-2273-8-git-send-email-lindner_marek@yahoo.de>
References: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4.bullet.mail.ukl.yahoo.com ([217.146.182.225]:47884 "HELO
	nm4.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752897Ab1HXNBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 09:01:15 -0400
In-Reply-To: <1314190838-2273-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/aggregation.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/aggregation.h b/net/batman-adv/aggregation.h
index 216337b..df4a5a9 100644
--- a/net/batman-adv/aggregation.h
+++ b/net/batman-adv/aggregation.h
@@ -28,8 +28,7 @@
 static inline int aggregated_packet(int buff_pos, int packet_len,
 				    int tt_num_changes)
 {
-	int next_buff_pos = buff_pos + BAT_PACKET_LEN + (tt_num_changes *
-						sizeof(struct tt_change));
+	int next_buff_pos = buff_pos + BAT_PACKET_LEN + tt_len(tt_num_changes);
 
 	return (next_buff_pos <= packet_len) &&
 		(next_buff_pos <= MAX_AGGREGATION_BYTES);
-- 
1.7.5.3
