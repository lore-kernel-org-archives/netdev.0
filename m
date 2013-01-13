From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/15] batman-adv: remove unused variable from orig_node struct
Date: Mon, 14 Jan 2013 09:41:19 +1000
Message-ID: <1358120480-25960-15-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49986 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800Ab3AMXn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:43:27 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 030ce41..441880a 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -119,7 +119,6 @@ struct batadv_orig_node {
 	spinlock_t ogm_cnt_lock;
 	/* bcast_seqno_lock protects bcast_bits, last_bcast_seqno */
 	spinlock_t bcast_seqno_lock;
-	spinlock_t tt_list_lock; /* protects tt_list */
 	atomic_t bond_candidates;
 	struct list_head bond_list;
 };
-- 
1.8.0.2
