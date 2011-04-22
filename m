From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 4/9] net-tcp: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:02 -0700
Message-ID: <1303515367-25595-5-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
 <1303515367-25595-3-git-send-email-maheshb@google.com>
 <1303515367-25595-4-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28944 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757035Ab1DVXgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:18 -0400
In-Reply-To: <1303515367-25595-4-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/net/tcp.h |    2 +-
 net/ipv4/tcp.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..bcfd5cb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1396,7 +1396,7 @@ extern struct request_sock_ops tcp6_request_sock_ops;
 extern void tcp_v4_destroy_sock(struct sock *sk);
 
 extern int tcp_v4_gso_send_check(struct sk_buff *skb);
-extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 features);
+extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u64 features);
 extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb);
 extern struct sk_buff **tcp4_gro_receive(struct sk_buff **head,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 054a59d..1320523 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2654,7 +2654,7 @@ int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u64 features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct tcphdr *th;
-- 
1.7.3.1

