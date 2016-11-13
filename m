From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 38/39] netfilter: conntrack: remove unused netns_ct member
Date: Sun, 13 Nov 2016 23:25:32 +0100
Message-ID: <1479075933-4491-39-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

since 23014011ba420 ('netfilter: conntrack: support a fixed size of 128 distinct labels')
this isn't needed anymore.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index e469e85de3f9..3d06d94d2e52 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -91,7 +91,6 @@ struct netns_ct {
 	struct nf_ip_net	nf_ct_proto;
 #if defined(CONFIG_NF_CONNTRACK_LABELS)
 	unsigned int		labels_used;
-	u8			label_words;
 #endif
 };
 #endif
-- 
2.1.4

