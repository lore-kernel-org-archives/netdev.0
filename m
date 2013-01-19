From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/13] batman-adv: align kernel doc properly
Date: Sat, 19 Jan 2013 21:27:48 +0800
Message-ID: <1358602079-24024-3-git-send-email-ordex@autistici.org>
References: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:57570 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab3ASN3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 08:29:34 -0500
In-Reply-To: <1358602079-24024-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index d8061ac..dffbdff 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -66,19 +66,18 @@ struct batadv_hard_iface {
 };
 
 /**
- *	struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
- *	@primary_addr: hosts primary interface address
- *	@last_seen: when last packet from this node was received
- *	@bcast_seqno_reset: time when the broadcast seqno window was reset
- *	@batman_seqno_reset: time when the batman seqno window was reset
- *	@gw_flags: flags related to gateway class
- *	@flags: for now only VIS_SERVER flag
- *	@last_real_seqno: last and best known sequence number
- *	@last_ttl: ttl of last received packet
- *	@last_bcast_seqno: last broadcast sequence number received by this host
- *
- *	@candidates: how many candidates are available
- *	@selected: next bonding candidate
+ * struct batadv_orig_node - structure for orig_list maintaining nodes of mesh
+ * @primary_addr: hosts primary interface address
+ * @last_seen: when last packet from this node was received
+ * @bcast_seqno_reset: time when the broadcast seqno window was reset
+ * @batman_seqno_reset: time when the batman seqno window was reset
+ * @gw_flags: flags related to gateway class
+ * @flags: for now only VIS_SERVER flag
+ * @last_real_seqno: last and best known sequence number
+ * @last_ttl: ttl of last received packet
+ * @last_bcast_seqno: last broadcast sequence number received by this host
+ * @candidates: how many candidates are available
+ * @selected: next bonding candidate
  */
 struct batadv_orig_node {
 	uint8_t orig[ETH_ALEN];
-- 
1.8.0.2
