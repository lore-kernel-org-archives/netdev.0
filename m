From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 4/4] af_unix: remove unused struct sockaddr_un cruft
Date: Fri,  4 Mar 2011 22:45:06 +0100
Message-ID: <1299275106-11513-4-git-send-email-hagen@jauu.net>
References: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Cc: Hagen Paul Pfeifer <hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:39158 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760261Ab1CDVpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 16:45:10 -0500
In-Reply-To: <1299275106-11513-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/unix/af_unix.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 217fb7f..df5997d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1567,7 +1567,6 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	struct sock_iocb *siocb = kiocb_to_siocb(kiocb);
 	struct sock *sk = sock->sk;
 	struct sock *other = NULL;
-	struct sockaddr_un *sunaddr = msg->msg_name;
 	int err, size;
 	struct sk_buff *skb;
 	int sent = 0;
@@ -1590,7 +1589,6 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		err = sk->sk_state == TCP_ESTABLISHED ? -EISCONN : -EOPNOTSUPP;
 		goto out_err;
 	} else {
-		sunaddr = NULL;
 		err = -ENOTCONN;
 		other = unix_peer(sk);
 		if (!other)
-- 
1.7.4.1.57.g0466.dirty

