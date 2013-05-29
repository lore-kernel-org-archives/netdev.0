From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/21] batman-adv: slightly improve neighbor creation debug message
Date: Wed, 29 May 2013 02:59:30 +0200
Message-ID: <1369789186-3600-6-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43859 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759017Ab3E2BBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:49 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

print the interface along with the new neighbor mac address

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/originator.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index ddf5634..f50553a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -110,7 +110,8 @@ batadv_neigh_node_new(struct batadv_hard_iface *hard_iface,
 	atomic_set(&neigh_node->refcount, 2);
 
 	batadv_dbg(BATADV_DBG_BATMAN, bat_priv,
-		   "Creating new neighbor %pM\n", neigh_addr);
+		   "Creating new neighbor %pM on interface %s\n", neigh_addr,
+		   hard_iface->net_dev->name);
 
 out:
 	return neigh_node;
-- 
1.8.1.5
