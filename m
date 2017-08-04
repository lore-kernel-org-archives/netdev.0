From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] lwtunnel: replace EXPORT_SYMBOL with EXPORT_SYMBOL_GPL
Date: Fri,  4 Aug 2017 15:23:37 -0700
Message-ID: <1501885417-18966-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33591 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdHDWXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 18:23:43 -0400
Received: by mail-pg0-f48.google.com with SMTP id u5so12821887pgn.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 15:23:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/lwtunnel.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index d9cb353..8693ff8 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -65,7 +65,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
 
 	return lws;
 }
-EXPORT_SYMBOL(lwtunnel_state_alloc);
+EXPORT_SYMBOL_GPL_GPL(lwtunnel_state_alloc);
 
 static const struct lwtunnel_encap_ops __rcu *
 		lwtun_encaps[LWTUNNEL_ENCAP_MAX + 1] __read_mostly;
@@ -80,7 +80,7 @@ int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
 			&lwtun_encaps[num],
 			NULL, ops) ? 0 : -1;
 }
-EXPORT_SYMBOL(lwtunnel_encap_add_ops);
+EXPORT_SYMBOL_GPL(lwtunnel_encap_add_ops);
 
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 			   unsigned int encap_type)
@@ -99,7 +99,7 @@ int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *ops,
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_encap_del_ops);
+EXPORT_SYMBOL_GPL(lwtunnel_encap_del_ops);
 
 int lwtunnel_build_state(u16 encap_type,
 			 struct nlattr *encap, unsigned int family,
@@ -138,7 +138,7 @@ int lwtunnel_build_state(u16 encap_type,
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_build_state);
+EXPORT_SYMBOL_GPL(lwtunnel_build_state);
 
 int lwtunnel_valid_encap_type(u16 encap_type, struct netlink_ext_ack *extack)
 {
@@ -175,7 +175,7 @@ int lwtunnel_valid_encap_type(u16 encap_type, struct netlink_ext_ack *extack)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_valid_encap_type);
+EXPORT_SYMBOL_GPL(lwtunnel_valid_encap_type);
 
 int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining,
 				   struct netlink_ext_ack *extack)
@@ -205,7 +205,7 @@ int lwtunnel_valid_encap_type_attr(struct nlattr *attr, int remaining,
 
 	return 0;
 }
-EXPORT_SYMBOL(lwtunnel_valid_encap_type_attr);
+EXPORT_SYMBOL_GPL(lwtunnel_valid_encap_type_attr);
 
 void lwtstate_free(struct lwtunnel_state *lws)
 {
@@ -219,7 +219,7 @@ void lwtstate_free(struct lwtunnel_state *lws)
 	}
 	module_put(ops->owner);
 }
-EXPORT_SYMBOL(lwtstate_free);
+EXPORT_SYMBOL_GPL(lwtstate_free);
 
 int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 {
@@ -259,7 +259,7 @@ int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 
 	return (ret == -EOPNOTSUPP ? 0 : ret);
 }
-EXPORT_SYMBOL(lwtunnel_fill_encap);
+EXPORT_SYMBOL_GPL(lwtunnel_fill_encap);
 
 int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate)
 {
@@ -281,7 +281,7 @@ int lwtunnel_get_encap_size(struct lwtunnel_state *lwtstate)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_get_encap_size);
+EXPORT_SYMBOL_GPL(lwtunnel_get_encap_size);
 
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 {
@@ -309,7 +309,7 @@ int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_cmp_encap);
+EXPORT_SYMBOL_GPL(lwtunnel_cmp_encap);
 
 int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -343,7 +343,7 @@ int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_output);
+EXPORT_SYMBOL_GPL(lwtunnel_output);
 
 int lwtunnel_xmit(struct sk_buff *skb)
 {
@@ -378,7 +378,7 @@ int lwtunnel_xmit(struct sk_buff *skb)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_xmit);
+EXPORT_SYMBOL_GPL(lwtunnel_xmit);
 
 int lwtunnel_input(struct sk_buff *skb)
 {
@@ -412,4 +412,4 @@ int lwtunnel_input(struct sk_buff *skb)
 
 	return ret;
 }
-EXPORT_SYMBOL(lwtunnel_input);
+EXPORT_SYMBOL_GPL(lwtunnel_input);
-- 
2.1.4
