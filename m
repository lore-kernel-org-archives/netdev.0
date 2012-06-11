From: pablo@netfilter.org
Subject: [PATCH 23/25] netfilter: ipv4, defrag: switch hook PFs to nfproto
Date: Mon, 11 Jun 2012 16:43:59 +0200
Message-ID: <1339425841-24171-24-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Crequy <alban.crequy@collabora.co.uk>

This patch is a cleanup. Use NFPROTO_* for consistency with other
netfilter code.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
Reviewed-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Reviewed-by: Vincent Sanders <vincent.sanders@collabora.co.uk>
---
 net/ipv4/netfilter/nf_defrag_ipv4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 9bb1b8a..7428155 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -94,14 +94,14 @@ static struct nf_hook_ops ipv4_defrag_ops[] = {
 	{
 		.hook		= ipv4_conntrack_defrag,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook           = ipv4_conntrack_defrag,
 		.owner          = THIS_MODULE,
-		.pf             = PF_INET,
+		.pf             = NFPROTO_IPV4,
 		.hooknum        = NF_INET_LOCAL_OUT,
 		.priority       = NF_IP_PRI_CONNTRACK_DEFRAG,
 	},
-- 
1.7.10

