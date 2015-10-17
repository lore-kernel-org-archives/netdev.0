From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/35] netfilter: ipv4: code indentation
Date: Sat, 17 Oct 2015 13:33:09 +0200
Message-ID: <1445081590-2924-35-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48469 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752874AbbJQL0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:34 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Use tabs instead of spaces to indent code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ip_tables.c        | 6 +++---
 net/ipv4/netfilter/ipt_SYNPROXY.c     | 2 +-
 net/ipv4/netfilter/iptable_security.c | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3991a87..b99affa 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -431,8 +431,8 @@ ipt_do_table(struct sk_buff *skb,
 	} while (!acpar.hotdrop);
 	pr_debug("Exiting %s; sp at %u\n", __func__, stackidx);
 
- 	xt_write_recseq_end(addend);
- 	local_bh_enable();
+	xt_write_recseq_end(addend);
+	local_bh_enable();
 
 #ifdef DEBUG_ALLOW_ALL
 	return NF_ACCEPT;
@@ -484,7 +484,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
-			    		    XT_STANDARD_TARGET) == 0) &&
+					    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index f105b6f..a105836 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -231,7 +231,7 @@ synproxy_send_client_ack(const struct synproxy_net *snet,
 	synproxy_build_options(nth, opts);
 
 	synproxy_send_tcp(snet, skb, nskb, skb->nfct, IP_CT_ESTABLISHED_REPLY,
-	                  niph, nth, tcp_hdr_size);
+			  niph, nth, tcp_hdr_size);
 }
 
 static bool
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index f534e2f..c2e23d5 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -79,7 +79,7 @@ static int __init iptable_security_init(void)
 	int ret;
 
 	ret = register_pernet_subsys(&iptable_security_net_ops);
-        if (ret < 0)
+	if (ret < 0)
 		return ret;
 
 	sectbl_ops = xt_hook_link(&security_table, iptable_security_hook);
-- 
2.1.4
