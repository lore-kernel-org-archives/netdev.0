From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 5/8] batman-adv: use shorter pr_warn instead of pr_warning
Date: Mon, 14 May 2012 09:17:35 +0200
Message-ID: <1336979858-13928-6-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51725 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668Ab2ENHRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:11 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |    6 +++---
 net/batman-adv/send.c           |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 0b84bb1..dc334fa 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -173,9 +173,9 @@ static void check_known_mac_addr(const struct net_device *net_dev)
 				 net_dev->dev_addr))
 			continue;
 
-		pr_warning("The newly added mac address (%pM) already exists on: %s\n",
-			   net_dev->dev_addr, hard_iface->net_dev->name);
-		pr_warning("It is strongly recommended to keep mac addresses unique to avoid problems!\n");
+		pr_warn("The newly added mac address (%pM) already exists on: %s\n",
+			net_dev->dev_addr, hard_iface->net_dev->name);
+		pr_warn("It is strongly recommended to keep mac addresses unique to avoid problems!\n");
 	}
 	rcu_read_unlock();
 }
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 8e74d97..f47299f 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -45,8 +45,8 @@ int send_skb_packet(struct sk_buff *skb, struct hard_iface *hard_iface,
 		goto send_skb_err;
 
 	if (!(hard_iface->net_dev->flags & IFF_UP)) {
-		pr_warning("Interface %s is not up - can't send packet via that interface!\n",
-			   hard_iface->net_dev->name);
+		pr_warn("Interface %s is not up - can't send packet via that interface!\n",
+			hard_iface->net_dev->name);
 		goto send_skb_err;
 	}
 
-- 
1.7.9.4
