From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: define nat_pptp_info as needed
Date: Sun, 14 Nov 2010 19:47:48 +0800
Message-ID: <1289735268-13791-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/netfilter/nf_nat.h |    2 ++
 1 file changed, 2 insertions(+)
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index f5f09f0..d082938 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -56,7 +56,9 @@ struct nf_nat_multi_range_compat {
 /* per conntrack: nat application helper private data */
 union nf_conntrack_nat_help {
 	/* insert nat helper private data here */
+#if defined(CONFIG_NF_NAT_PPTP) || defined(CONFIG_NF_NAT_PPTP_MODULE)
 	struct nf_nat_pptp nat_pptp_info;
+#endif
 };
 
 struct nf_conn;
