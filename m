From: akpm@osdl.org
Subject: [patch 15/18] gcc-3.5: net/rose
Date: Sun, 25 Jan 2004 03:08:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251108.i0PB89o25130@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/rose/af_rose.c: In function `rose_alloc_sock':
net/rose/af_rose.c:136: error: invalid lvalue in assignment



---

 net/rose/af_rose.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/rose/af_rose.c~gcc-35-rose net/rose/af_rose.c
--- 25/net/rose/af_rose.c~gcc-35-rose	2004-01-23 21:38:29.000000000 -0800
+++ 25-akpm/net/rose/af_rose.c	2004-01-23 21:38:52.000000000 -0800
@@ -133,7 +133,7 @@ static struct sock *rose_alloc_sock(void
 	if (!sk)
 		goto out;
 
-	rose = rose_sk(sk) = kmalloc(sizeof(*rose), GFP_ATOMIC);
+	rose = sk->sk_protinfo = kmalloc(sizeof(*rose), GFP_ATOMIC);
 	if (!rose)
 		goto frees;
 

_
