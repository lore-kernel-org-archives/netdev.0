From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 2/3] ipv6: Export nf_ct_frag6_consume_orig()
Date: Fri, 23 Oct 2015 16:01:50 -0700
Message-ID: <1445641311-63081-2-git-send-email-joestringer@nicira.com>
References: <1445641311-63081-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35954 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393AbbJWXCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 19:02:01 -0400
Received: by pacfv9 with SMTP id fv9so135629473pac.3
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 16:02:01 -0700 (PDT)
In-Reply-To: <1445641311-63081-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed in openvswitch to fix an skb leak in the next patch.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 701cd2bae0a9..c7196ad1d69f 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -646,6 +646,7 @@ void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 		s = s2;
 	}
 }
+EXPORT_SYMBOL_GPL(nf_ct_frag6_consume_orig);
 
 static int nf_ct_net_init(struct net *net)
 {
-- 
2.1.4
