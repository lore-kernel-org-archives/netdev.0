From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/1] [INET]: Remove leftover prototypes from
	include/net/inet_common.h
Date: Wed, 7 Nov 2007 17:20:16 -0200
Message-ID: <20071107192016.GB32752@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:40958 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486AbXKGTUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 14:20:31 -0500
Received: by an-out-0708.google.com with SMTP id b36so333622ana
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2007 11:20:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/inet_common.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_common.h b/include/net/inet_common.h
index 227adcb..38d5a1e 100644
--- a/include/net/inet_common.h
+++ b/include/net/inet_common.h
@@ -13,9 +13,6 @@ struct sock;
 struct sockaddr;
 struct socket;
 
-extern void			inet_remove_sock(struct sock *sk1);
-extern void			inet_put_sock(unsigned short num, 
-					      struct sock *sk);
 extern int			inet_release(struct socket *sock);
 extern int			inet_stream_connect(struct socket *sock,
 						    struct sockaddr * uaddr,
@@ -30,7 +27,6 @@ extern int			inet_sendmsg(struct kiocb *iocb,
 					     struct msghdr *msg, 
 					     size_t size);
 extern int			inet_shutdown(struct socket *sock, int how);
-extern unsigned int		inet_poll(struct file * file, struct socket *sock, struct poll_table_struct *wait);
 extern int			inet_listen(struct socket *sock, int backlog);
 
 extern void			inet_sock_destruct(struct sock *sk);
-- 
1.5.3.4

