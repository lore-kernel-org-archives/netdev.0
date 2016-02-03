From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 14/16] batman-adv: Fix kernel-doc for batadv_claim_free_ref
Date: Wed,  3 Feb 2016 10:18:35 +0800
Message-ID: <1454465917-13332-15-git-send-email-a__20751.9278898419$1454467247$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:1742 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755374AbcBCCkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:32 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 131aca049907..b3a72e29a167 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -165,7 +165,8 @@ static void batadv_claim_release(struct batadv_bla_claim *claim)
 }
 
 /**
- * batadv_claim_free_rcu - free a claim
+ * batadv_claim_free_ref - decrement the claim refcounter and possibly
+ *  release it
  * @claim: claim to be free'd
  */
 static void batadv_claim_free_ref(struct batadv_bla_claim *claim)
-- 
2.7.0
