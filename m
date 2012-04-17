From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 12/12] netfilter: export necessary function for generic proto
Date: Tue, 17 Apr 2012 10:56:23 +0800
Message-ID: <1334631383-12326-13-git-send-email-gaofeng@cn.fujitsu.com>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

export two functions nf_conntrack_proto_generic_net_init and
nf_conntrack_proto_generic_net_fini.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_core.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index aced085..3c3fabe 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -31,6 +31,9 @@ extern void nf_conntrack_cleanup(struct net *net);
 extern int nf_conntrack_proto_init(void);
 extern void nf_conntrack_proto_fini(void);
 
+extern int nf_conntrack_proto_generic_net_init(struct net *net);
+extern void nf_conntrack_proto_generic_net_fini(struct net *net);
+
 extern bool
 nf_ct_get_tuple(const struct sk_buff *skb,
 		unsigned int nhoff,
-- 
1.7.7.6

