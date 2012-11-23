From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] tcp: remove dead prototype for tcp_v4_get_peer()
Date: Thu, 22 Nov 2012 22:48:59 -0500
Message-ID: <1353642539-6509-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f74.google.com ([74.125.82.74]:53640 "EHLO
	mail-wg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896Ab2KWDtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 22:49:05 -0500
Received: by mail-wg0-f74.google.com with SMTP id dt14so582219wgb.1
        for <netdev@vger.kernel.org>; Thu, 22 Nov 2012 19:49:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function no longer exists.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6feeccd..3202bde 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -369,7 +369,6 @@ extern void tcp_shutdown (struct sock *sk, int how);
 extern void tcp_v4_early_demux(struct sk_buff *skb);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
-extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
 extern int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 extern int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		       size_t size);
-- 
1.7.7.3
