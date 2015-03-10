From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next v2 5/5] net: export symbol nf_ct_frag6_consume_orig
Date: Tue, 10 Mar 2015 12:07:18 -0700
Message-ID: <1426014438-9317-6-git-send-email-azhou@nicira.com>
References: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog136.obsmtp.com ([74.125.149.85]:51227 "HELO
	na3sys009aog136.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751330AbbCJTQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 15:16:45 -0400
Received: by mail-pa0-f54.google.com with SMTP id eu11so4632366pac.1
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 12:16:44 -0700 (PDT)
In-Reply-To: <1426014438-9317-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Openvswitch conntrack support needs to access this function.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 9d36db9..b8ffde9 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -652,6 +652,7 @@ void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 		s = s2;
 	}
 }
+EXPORT_SYMBOL(nf_ct_frag6_consume_orig);
 
 static int nf_ct_net_init(struct net *net)
 {
-- 
1.9.1
