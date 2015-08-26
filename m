From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv6 net-next 03/10] ipv6: Export nf_ct_frag6_gather()
Date: Wed, 26 Aug 2015 11:31:46 -0700
Message-ID: <1440613913-10141-4-git-send-email-joestringer@nicira.com>
References: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com,
	netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34159 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbbHZScE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:32:04 -0400
Received: by pabzx8 with SMTP id zx8so78011262pab.1
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:32:03 -0700 (PDT)
In-Reply-To: <1440613913-10141-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v4: Add ack.
v5-v6: No change.
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
