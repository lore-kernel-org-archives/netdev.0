From: akpm@osdl.org
Subject: [patch 5/18] gcc-3.5: econet
Date: Sun, 25 Jan 2004 03:07:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7Bo25065@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/econet/af_econet.c: In function `econet_create':
net/econet/af_econet.c:571: error: invalid lvalue in assignment



---

 25-akpm/net/econet/af_econet.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/econet/af_econet.c~gcc-35-econet net/econet/af_econet.c
--- 25/net/econet/af_econet.c~gcc-35-econet	Fri Jan 23 15:30:25 2004
+++ 25-akpm/net/econet/af_econet.c	Fri Jan 23 15:30:40 2004
@@ -568,7 +568,7 @@ static int econet_create(struct socket *
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	eo = ec_sk(sk) = kmalloc(sizeof(*eo), GFP_KERNEL);
+	eo = sk->sk_protinfo = kmalloc(sizeof(*eo), GFP_KERNEL);
 	if (!eo)
 		goto out_free;
 	memset(eo, 0, sizeof(*eo));

_
