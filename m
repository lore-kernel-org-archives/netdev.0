From: akpm@osdl.org
Subject: [patch 13/18] gcc-3.5: netrom
Date: Sun, 25 Jan 2004 03:07:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7wo25107@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/netrom/af_netrom.c: In function `nr_alloc_sock':
net/netrom/af_netrom.c:75: error: invalid lvalue in assignment



---

 25-akpm/net/netrom/af_netrom.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/netrom/af_netrom.c~gcc-35-netrom net/netrom/af_netrom.c
--- 25/net/netrom/af_netrom.c~gcc-35-netrom	Fri Jan 23 16:50:31 2004
+++ 25-akpm/net/netrom/af_netrom.c	Fri Jan 23 16:50:47 2004
@@ -72,7 +72,7 @@ static struct sock *nr_alloc_sock(void)
 	if (!sk)
 		goto out;
 
-	nr = nr_sk(sk) = kmalloc(sizeof(*nr), GFP_ATOMIC);
+	nr = sk->sk_protinfo = kmalloc(sizeof(*nr), GFP_ATOMIC);
 	if (!nr)
 		goto frees;
 

_
