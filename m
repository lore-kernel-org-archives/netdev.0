From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/7] netfilter: conntrack: remove leftover binary sysctl define
Date: Wed,  1 Jun 2016 14:03:19 +0200
Message-ID: <1464782604-19346-3-git-send-email-pablo@netfilter.org>
References: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1464782604-19346-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Users got removed in f8572d8f2a2ba ("sysctl net: Remove unused binary
sysctl code").

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_standalone.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0f1a45b..2933db3 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -489,8 +489,6 @@ static struct ctl_table nf_ct_sysctl_table[] = {
 	{ }
 };
 
-#define NET_NF_CONNTRACK_MAX 2089
-
 static struct ctl_table nf_ct_netfilter_table[] = {
 	{
 		.procname	= "nf_conntrack_max",
-- 
2.1.4

