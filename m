From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 16/16] batman-adv: Use common declaration order in *_send_skb_(packet|unicast)
Date: Fri, 29 May 2015 11:05:28 +0200
Message-ID: <1432890328-8247-17-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:36268 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755692AbbE2JVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:21:30 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/send.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index fa70ae8..23635bd 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -255,8 +255,8 @@ int batadv_send_skb_unicast(struct batadv_priv *bat_priv,
 			    struct batadv_orig_node *orig_node,
 			    unsigned short vid)
 {
-	struct ethhdr *ethhdr;
 	struct batadv_unicast_packet *unicast_packet;
+	struct ethhdr *ethhdr;
 	int ret = NET_XMIT_DROP;
 
 	if (!orig_node)
-- 
2.4.2
