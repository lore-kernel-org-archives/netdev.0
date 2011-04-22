From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 5/9] net-udp: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:03 -0700
Message-ID: <1303515367-25595-6-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
 <1303515367-25595-4-git-send-email-maheshb@google.com>
 <1303515367-25595-5-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28953 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049Ab1DVXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:19 -0400
In-Reply-To: <1303515367-25595-5-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/net/udp.h |    2 +-
 net/ipv4/udp.c    |    2 +-
 net/ipv6/udp.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 67ea6fc..7a3779c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -256,5 +256,5 @@ extern void udp4_proc_exit(void);
 extern void udp_init(void);
 
 extern int udp4_ufo_send_check(struct sk_buff *skb);
-extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 features);
+extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u64 features);
 #endif	/* _UDP_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index bc0dab2..e06d546 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2230,7 +2230,7 @@ int udp4_ufo_send_check(struct sk_buff *skb)
 	return 0;
 }
 
-struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 features)
+struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	unsigned int mss;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1bdc5f0..9f8ad70 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1295,7 +1295,7 @@ static int udp6_ufo_send_check(struct sk_buff *skb)
 	return 0;
 }
 
-static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 features)
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	unsigned int mss;
-- 
1.7.3.1

