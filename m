From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 1/2] net: ping: make local functions static
Date: Thu, 19 May 2011 15:16:00 +0800
Message-ID: <1305789361-5366-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:41085 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755777Ab1ESHQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 03:16:59 -0400
Received: by pzk9 with SMTP id 9so1059935pzk.19
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 00:16:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As these functions are only used in this file.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/ping.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 6a21da9..5f9e2d1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -449,8 +449,8 @@ static int ping_push_pending_frames(struct sock *sk, struct pingfakehdr *pfh, st
 	return ip_push_pending_frames(sk, fl4);
 }
 
-int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len)
+static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+			size_t len)
 {
 	struct net *net = sock_net(sk);
 	struct flowi4 fl4;
@@ -621,8 +621,8 @@ do_confirm:
 	goto out;
 }
 
-int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
-		 size_t len, int noblock, int flags, int *addr_len)
+static int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+			size_t len, int noblock, int flags, int *addr_len)
 {
 	struct inet_sock *isk = inet_sk(sk);
 	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
