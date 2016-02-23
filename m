From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 01/20] batman-adv: remove unused BATADV_BONDING_TQ_THRESHOLD constant
Date: Tue, 23 Feb 2016 14:08:04 +0800
Message-ID: <1456207703-903-2-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:9158 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbcBWGKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:10:50 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BATADV_BONDING_TQ_THRESHOLD is not used anymore since the implementation
of the bat_neigh_is_similar_or_better() API function.
Such function uses the more generic BATADV_TQ_SIMILARITY_THRESHOLD
constant.

Therefore, remove definition of the unused BATADV_BONDING_TQ_THRESHOLD
constant.

Signed-off-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/main.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 32dfc9e578af..8c01f54c61f3 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -100,11 +100,6 @@
  */
 #define BATADV_TQ_SIMILARITY_THRESHOLD 50
 
-/* how much worse secondary interfaces may be to be considered as bonding
- * candidates
- */
-#define BATADV_BONDING_TQ_THRESHOLD	50
-
 /* should not be bigger than 512 bytes or change the size of
  * forw_packet->direct_link_flags
  */
-- 
2.7.1
