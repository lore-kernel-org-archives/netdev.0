From: akpm@osdl.org
Subject: [patch 1/18] gcc-3.5: appletalk
Date: Sun, 25 Jan 2004 03:06:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251106.i0PB6mo25011@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/appletalk/ddp.c: In function `atalk_create':
net/appletalk/ddp.c:1054: error: invalid lvalue in assignment



---

 25-akpm/net/appletalk/ddp.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/appletalk/ddp.c~gcc-35-appletalk net/appletalk/ddp.c
--- 25/net/appletalk/ddp.c~gcc-35-appletalk	Fri Jan 23 15:03:44 2004
+++ 25-akpm/net/appletalk/ddp.c	Fri Jan 23 15:04:33 2004
@@ -1051,7 +1051,7 @@ static int atalk_create(struct socket *s
 	sk = sk_alloc(PF_APPLETALK, GFP_KERNEL, 1, NULL);
 	if (!sk)
 		goto out;
-	at = at_sk(sk) = kmalloc(sizeof(*at), GFP_KERNEL);
+	at = sk->sk_protinfo = kmalloc(sizeof(*at), GFP_KERNEL);
 	if (!at)
 		goto outsk;
 	memset(at, 0, sizeof(*at));

_
