From: pablo@netfilter.org
Subject: [PATCH 16/18] netfilter: nf_ct_tcp: missing per-net support for cttimeout
Date: Fri,  6 Jul 2012 13:17:06 +0200
Message-ID: <1341573428-3204-17-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds missing per-net support for the cttimeout
infrastructure to TCP.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 07e56ea..a5ac11e 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -821,7 +821,7 @@ static int tcp_error(struct net *net, struct nf_conn *tmpl,
 
 static unsigned int *tcp_get_timeouts(struct net *net)
 {
-	return tcp_timeouts;
+	return tcp_pernet(net)->timeouts;
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
-- 
1.7.10

