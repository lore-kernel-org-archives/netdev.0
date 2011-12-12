From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 08/11] batman-adv: format multi-line if in the correct way
Date: Mon, 12 Dec 2011 19:31:52 +0800
Message-ID: <1323689516-24427-9-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm17.bullet.mail.ukl.yahoo.com ([217.146.183.191]:33107 "HELO
	nm17.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752710Ab1LLLc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:58 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

in an multi-line if statement leading edges should line up to the opening
parenthesis

Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/routing.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index ef24a72..773e606 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -627,8 +627,7 @@ int recv_tt_query(struct sk_buff *skb, struct hard_iface *recv_if)
 
 			/* Ensure we have all the claimed data */
 			if (unlikely(skb_headlen(skb) <
-					sizeof(struct tt_query_packet) +
-					tt_len))
+				     sizeof(struct tt_query_packet) + tt_len))
 				goto out;
 
 			handle_tt_response(bat_priv, tt_query);
-- 
1.7.5.4
