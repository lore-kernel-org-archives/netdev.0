From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 04/27] afnetns: add net_afnetns
Date: Mon, 13 Mar 2017 00:01:28 +0100
Message-ID: <20170312230151.5185-5-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57119 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935571AbdCLXCI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:08 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 8555A206F7
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:56 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id E186F2436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:55 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/net_namespace.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index c59fb018da5e46..9be39b8315a6f9 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -244,6 +244,14 @@ int net_eq(const struct net *net1, const struct net *net2)
 #define net_drop_ns NULL
 #endif
 
+static inline struct afnetns *net_afnetns(struct net *net)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	return net->afnet_ns;
+#else
+	return NULL;
+#endif
+}
 
 typedef struct {
 #ifdef CONFIG_NET_NS
-- 
2.9.3
