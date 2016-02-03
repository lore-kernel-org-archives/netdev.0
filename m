From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/16] batman-adv: add kernel doc for AP isolation attributes in bat_priv
Date: Wed,  3 Feb 2016 10:18:33 +0800
Message-ID: <1454465917-13332-13-git-send-email-a@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:21858 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754827AbcBCCkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:40:19 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/types.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 7f7a0f1eaf75..5e8c8df4c4ac 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -772,6 +772,9 @@ struct batadv_softif_vlan {
  * @orig_interval: OGM broadcast interval in milliseconds
  * @hop_penalty: penalty which will be applied to an OGM's tq-field on every hop
  * @log_level: configured log level (see batadv_dbg_level)
+ * @isolation_mark: the skb->mark value used to match packets for AP isolation
+ * @isolation_mark_mask: bitmask identifying the bits in skb->mark to be used
+ *  for the isolation mark
  * @bcast_seqno: last sent broadcast packet sequence number
  * @bcast_queue_left: number of remaining buffered broadcast packet slots
  * @batman_queue_left: number of remaining OGM packet slots
-- 
2.7.0
