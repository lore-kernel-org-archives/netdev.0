From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 07/11] batman-adv: remove extra negation in gw_out_of_range()
Date: Mon, 12 Dec 2011 19:31:51 +0800
Message-ID: <1323689516-24427-8-git-send-email-lindner_marek@yahoo.de>
References: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm9.bullet.mail.ukl.yahoo.com ([217.146.182.250]:26385 "HELO
	nm9.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752710Ab1LLLcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 06:32:53 -0500
In-Reply-To: <1323689516-24427-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

There is a typo here where an extra '!' made the check to the opposite
of what was intended.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/gateway_client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/gateway_client.c b/net/batman-adv/gateway_client.c
index 9373a14..24403a7 100644
--- a/net/batman-adv/gateway_client.c
+++ b/net/batman-adv/gateway_client.c
@@ -695,7 +695,7 @@ bool gw_out_of_range(struct bat_priv *bat_priv,
 	}
 
 	neigh_old = find_router(bat_priv, orig_dst_node, NULL);
-	if (!!neigh_old)
+	if (!neigh_old)
 		goto out;
 
 	if (curr_tq_avg - neigh_old->tq_avg > GW_THRESHOLD)
-- 
1.7.5.4
