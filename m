From: akpm@osdl.org
Subject: [patch 3/3] gcc-3.5: pppoe
Date: Thu, 5 Feb 2004 21:36:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402060536.i165a6N01687@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



drivers/net/pppoe.c: In function `pppoe_create':
drivers/net/pppoe.c:519: error: invalid lvalue in assignment                    


---

 drivers/net/pppoe.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/pppoe.c~gcc-35-pppoe drivers/net/pppoe.c
--- 25/drivers/net/pppoe.c~gcc-35-pppoe	2004-01-28 23:12:52.000000000 -0800
+++ 25-akpm/drivers/net/pppoe.c	2004-01-28 23:12:52.000000000 -0800
@@ -516,7 +516,7 @@ static int pppoe_create(struct socket *s
 	sk->sk_protocol	   = PX_PROTO_OE;
 	sk->sk_destruct	   = pppoe_sk_free;
 
-	po = pppox_sk(sk) = kmalloc(sizeof(*po), GFP_KERNEL);
+	po = sk->sk_protinfo = kmalloc(sizeof(*po), GFP_KERNEL);
 	if (!po)
 		goto frees;
 	memset(po, 0, sizeof(*po));

_
