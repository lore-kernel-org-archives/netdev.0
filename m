From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/18] batman-adv: move function arguments on one line
Date: Thu, 23 Aug 2012 15:10:10 +0200
Message-ID: <1345727427-20805-2-git-send-email-ordex@autistici.org>
References: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:28708 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab2HWNKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 09:10:47 -0400
In-Reply-To: <1345727427-20805-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 563cfbf..3f0dfa2 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -41,8 +41,7 @@ void batadv_bla_free(struct batadv_priv *bat_priv);
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
-				struct sk_buff *skb, short vid,
-				bool is_bcast)
+				struct sk_buff *skb, short vid, bool is_bcast)
 {
 	return 0;
 }
-- 
1.7.9.4
