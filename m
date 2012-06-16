From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] include/net/dst.h: neaten asterisk placement
Date: Sat, 16 Jun 2012 15:14:49 +0200
Message-ID: <1339852489-10632-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63336 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2FPNPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jun 2012 09:15:05 -0400
Received: by eeit10 with SMTP id t10so1171000eei.19
        for <netdev@vger.kernel.org>; Sat, 16 Jun 2012 06:15:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix code style - place the asterisk where it belongs.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 include/net/dst.h |   17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 8197ead..f0bf3b8 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -48,8 +48,8 @@ struct dst_entry {
 #else
 	void			*__pad1;
 #endif
-	int			(*input)(struct sk_buff*);
-	int			(*output)(struct sk_buff*);
+	int			(*input)(struct sk_buff *);
+	int			(*output)(struct sk_buff *);
 
 	int			flags;
 #define DST_HOST		0x0001
@@ -241,7 +241,7 @@ dst_metric_locked(const struct dst_entry *dst, int metric)
 	return dst_metric(dst, RTAX_LOCK) & (1<<metric);
 }
 
-static inline void dst_hold(struct dst_entry * dst)
+static inline void dst_hold(struct dst_entry *dst)
 {
 	/*
 	 * If your kernel compilation stops here, please check
@@ -264,8 +264,7 @@ static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 	dst->lastuse = time;
 }
 
-static inline
-struct dst_entry * dst_clone(struct dst_entry * dst)
+static inline struct dst_entry *dst_clone(struct dst_entry *dst)
 {
 	if (dst)
 		atomic_inc(&dst->__refcnt);
@@ -371,12 +370,12 @@ static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 }
 
 extern int dst_discard(struct sk_buff *skb);
-extern void *dst_alloc(struct dst_ops * ops, struct net_device *dev,
+extern void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
 		       int initial_ref, int initial_obsolete, int flags);
-extern void __dst_free(struct dst_entry * dst);
-extern struct dst_entry *dst_destroy(struct dst_entry * dst);
+extern void __dst_free(struct dst_entry *dst);
+extern struct dst_entry *dst_destroy(struct dst_entry *dst);
 
-static inline void dst_free(struct dst_entry * dst)
+static inline void dst_free(struct dst_entry *dst)
 {
 	if (dst->obsolete > 1)
 		return;
-- 
1.7.10
