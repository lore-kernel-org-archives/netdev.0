From: akpm@osdl.org
Subject: [patch 12/18] gcc-3.5: net/key/af_key.c
Date: Sun, 25 Jan 2004 03:07:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7qo25102@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/key/af_key.c: In function `pfkey_create':
net/key/af_key.c:151: error: invalid lvalue in assignment



---

 25-akpm/net/key/af_key.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/key/af_key.c~gcc-35-net-key net/key/af_key.c
--- 25/net/key/af_key.c~gcc-35-net-key	Fri Jan 23 16:41:35 2004
+++ 25-akpm/net/key/af_key.c	Fri Jan 23 16:42:00 2004
@@ -148,7 +148,7 @@ static int pfkey_create(struct socket *s
 	sk_set_owner(sk, THIS_MODULE);
 
 	err = -ENOMEM;
-	pfk = pfkey_sk(sk) = kmalloc(sizeof(*pfk), GFP_KERNEL);
+	pfk = sk->sk_protinfo = kmalloc(sizeof(*pfk), GFP_KERNEL);
 	if (!pfk) {
 		sk_free(sk);
 		goto out;

_
