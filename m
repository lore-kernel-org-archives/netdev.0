From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv4 net-next 03/10] ipv6: Export nf_ct_frag6_gather()
Date: Tue, 18 Aug 2015 16:39:41 -0700
Message-ID: <1439941188-19293-4-git-send-email-joestringer@nicira.com>
References: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, pablo@netfilter.org,
	fwestpha@redhat.com, hannes@redhat.com, tgraf@suug.ch,
	jpettit@nicira.com, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35553 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbbHRXmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 19:42:35 -0400
Received: by pacgr6 with SMTP id gr6so142894803pac.2
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 16:42:34 -0700 (PDT)
In-Reply-To: <1439941188-19293-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v4: Add ack.
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
