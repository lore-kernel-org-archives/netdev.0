From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/17] ipv6: remove obsolete inet6 functions
Date: Fri,  2 Oct 2015 11:43:34 -0700
Message-ID: <1443811419-4798-13-git-send-email-edumazet@google.com>
References: <1443811419-4798-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Ying Cai <ycai@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34322 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbbJBSoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 14:44:18 -0400
Received: by padhy16 with SMTP id hy16so113395480pad.1
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 11:44:18 -0700 (PDT)
In-Reply-To: <1443811419-4798-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet6_csk_search_req() and inet6_csk_reqsk_queue_hash_add()
no longer exist.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet6_connection_sock.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 79b2a4c09ca6..064cfbe639d0 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -28,15 +28,6 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
 				      const struct request_sock *req, u8 proto);
 
-struct request_sock *inet6_csk_search_req(struct sock *sk,
-					  const __be16 rport,
-					  const struct in6_addr *raddr,
-					  const struct in6_addr *laddr,
-					  const int iif);
-
-void inet6_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
-				    const unsigned long timeout);
-
 void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
 
 int inet6_csk_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl);
-- 
2.6.0.rc2.230.g3dd15c0
