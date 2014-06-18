From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/13] netfilter: ctnetlink: add zone size to length
Date: Wed, 18 Jun 2014 11:44:37 +0200
Message-ID: <1403084679-11227-12-git-send-email-pablo@netfilter.org>
References: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41530 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965716AbaFRJpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 05:45:09 -0400
In-Reply-To: <1403084679-11227-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 70123f4..300ed1e 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -597,6 +597,9 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_MARK */
 #endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	       + nla_total_size(sizeof(u_int16_t)) /* CTA_ZONE */
+#endif
 	       + ctnetlink_proto_size(ct)
 	       + ctnetlink_label_size(ct)
 	       ;
@@ -2040,6 +2043,9 @@ ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
 #ifdef CONFIG_NF_CONNTRACK_MARK
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_MARK */
 #endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	       + nla_total_size(sizeof(u_int16_t)) /* CTA_ZONE */
+#endif
 	       + ctnetlink_proto_size(ct)
 	       ;
 }
-- 
1.7.10.4
