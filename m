From: akpm@osdl.org
Subject: [patch 14/18] gcc-3.5: pppoe
Date: Sun, 25 Jan 2004 03:08:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251108.i0PB83o25125@mail.osdl.org>
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
--- 25/drivers/net/pppoe.c~gcc-35-pppoe	2004-01-25 03:01:42.000000000 -0800
+++ 25-akpm/drivers/net/pppoe.c	2004-01-25 03:01:42.000000000 -0800
@@ -517,7 +517,7 @@ static int pppoe_create(struct socket *s
 	sk->sk_protocol	   = PX_PROTO_OE;
 	sk->sk_destruct	   = pppoe_sk_free;
 
-	po = pppox_sk(sk) = kmalloc(sizeof(*po), GFP_KERNEL);
+	po = sk->sk_protinfo = kmalloc(sizeof(*po), GFP_KERNEL);
 	if (!po)
 		goto frees;
 	memset(po, 0, sizeof(*po));

_
