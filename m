From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 2/3] ipv6: Export nf_ct_frag6_consume_orig()
Date: Sun, 25 Oct 2015 20:21:49 -0700
Message-ID: <1445829710-11292-2-git-send-email-joestringer@nicira.com>
References: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Andy Zhou <azhou@nicira.com>
To: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34167 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbbJZDV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 23:21:56 -0400
Received: by padhk11 with SMTP id hk11so173880416pad.1
        for <netdev@vger.kernel.org>; Sun, 25 Oct 2015 20:21:55 -0700 (PDT)
In-Reply-To: <1445829710-11292-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed in openvswitch to fix an skb leak in the next patch.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2-v3: No change.
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
