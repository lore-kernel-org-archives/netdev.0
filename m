From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: sock_sendmsg_nosec() is static
Date: Tue, 26 Jul 2011 14:39:41 +0200
Message-ID: <1311683981.2355.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Anton Blanchard <anton@samba.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45239 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1GZMjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 08:39:47 -0400
Received: by wwe5 with SMTP id 5so470309wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 05:39:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Anton Blanchard <anton@samba.org>
---
 net/socket.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index 02dc82d..b7ce3b7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -580,7 +580,7 @@ int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 }
 EXPORT_SYMBOL(sock_sendmsg);
 
-int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
+static int sock_sendmsg_nosec(struct socket *sock, struct msghdr *msg, size_t size)
 {
 	struct kiocb iocb;
 	struct sock_iocb siocb;


