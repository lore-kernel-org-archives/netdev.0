From: Tomer Barletz <barletz@gmail.com>
Subject: [PATCH] netfilter: Initialize local variables to NULL, to prevent using them when uninitialized.
Date: Sat,  5 Dec 2015 02:08:43 -0800
Message-ID: <1449310123-31503-1-git-send-email-barletz@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tomer Barletz <barletz@gmail.com>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Tomer Barletz <barletz@gmail.com>
---
 net/netfilter/nfnetlink_queue.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 7d81d28..e8be660 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -313,7 +313,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 	struct net_device *outdev;
 	struct nf_conn *ct = NULL;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfnl_ct_hook *nfnl_ct;
+	struct nfnl_ct_hook *nfnl_ct = NULL;
 	bool csum_verify;
 	char *secdata = NULL;
 	u32 seclen = 0;
@@ -1041,7 +1041,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 	unsigned int verdict;
 	struct nf_queue_entry *entry;
 	enum ip_conntrack_info uninitialized_var(ctinfo);
-	struct nfnl_ct_hook *nfnl_ct;
+	struct nfnl_ct_hook *nfnl_ct = NULL;
 	struct nf_conn *ct = NULL;
 
 	struct net *net = sock_net(ctnl);
-- 
2.5.0

