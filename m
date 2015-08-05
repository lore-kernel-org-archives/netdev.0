From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net-next 3/9] ipv6: Export nf_ct_frag6_gather()
Date: Tue,  4 Aug 2015 21:49:53 -0700
Message-ID: <1438750199-9061-4-git-send-email-joestringer@nicira.com>
References: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org, kaber@trash.net,
	jpettit@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	jesse@nicira.com, fwestpha@redhat.com, hannes@redhat.com,
	tgraf@noironetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438750199-9061-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6d02498..701cd2b 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -633,6 +633,7 @@ ret_orig:
 	kfree_skb(clone);
 	return skb;
 }
+EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
 
 void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 {
-- 
2.1.4
