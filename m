From: akpm@osdl.org
Subject: [patch 7/18] gcc-3.5: ipx
Date: Sun, 25 Jan 2004 03:07:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7Mo25077@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/ipx/af_ipx.c: In function `ipx_create':
net/ipx/af_ipx.c:1354: error: invalid lvalue in assignment



---

 25-akpm/net/ipx/af_ipx.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/ipx/af_ipx.c~gcc-35-ipx net/ipx/af_ipx.c
--- 25/net/ipx/af_ipx.c~gcc-35-ipx	Fri Jan 23 15:40:35 2004
+++ 25-akpm/net/ipx/af_ipx.c	Fri Jan 23 15:40:53 2004
@@ -1351,7 +1351,7 @@ static int ipx_create(struct socket *soc
         	rc = -ENOMEM;
 		if (!sk)
 			goto out;
-		ipx = ipx_sk(sk) = kmalloc(sizeof(*ipx), GFP_KERNEL);
+		ipx = sk->sk_protinfo = kmalloc(sizeof(*ipx), GFP_KERNEL);
 		if (!ipx)
 			goto outsk;
 		memset(ipx, 0, sizeof(*ipx));

_
