From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next 1/2] openvswitch: Typo fix.
Date: Wed, 19 Apr 2017 18:55:10 -0700
Message-ID: <1492653311-99269-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay8-d.mail.gandi.net ([217.70.183.201]:57760 "EHLO
        relay8-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935613AbdDTBzY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 21:55:24 -0400
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
