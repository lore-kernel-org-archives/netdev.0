From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 5/6] netfilter-ipv4: code indentation
Date: Wed, 14 Oct 2015 23:17:07 +0100
Message-ID: <1444861028-21556-6-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:46080 "EHLO
	cedar.ipmorris.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754217AbbJNWRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 18:17:17 -0400
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use tabs instead of spaces to indent code.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
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
index 6a6e762..ff746b33 100644
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
1.9.1
