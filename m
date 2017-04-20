From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH 1/2] openvswitch: Typo fix.
Date: Wed, 19 Apr 2017 18:49:35 -0700
Message-ID: <1492652976-99201-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:59229 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938871AbdDTBzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 21:55:42 -0400
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net [217.70.183.199])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 3F45447F557
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 03:49:55 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix typo in a comment.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/conntrack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 7b2c2fc..58de4c2 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -373,7 +373,7 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
 	}
 
 	/* Labels are included in the IPCTNL_MSG_CT_NEW event only if the
-	 * IPCT_LABEL bit it set in the event cache.
+	 * IPCT_LABEL bit is set in the event cache.
 	 */
 	nf_conntrack_event_cache(IPCT_LABEL, ct);
 
-- 
2.1.4
