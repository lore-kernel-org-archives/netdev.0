From: akpm@osdl.org
Subject: [patch 2/18] gcc-3.5: net/atm/common.c
Date: Sun, 25 Jan 2004 03:06:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251106.i0PB6ro25015@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/atm/common.c: In function `vcc_create':
net/atm/common.c:151: error: invalid lvalue in assignment



---

 25-akpm/net/atm/common.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/atm/common.c~gcc-35-atm-common net/atm/common.c
--- 25/net/atm/common.c~gcc-35-atm-common	Fri Jan 23 15:15:46 2004
+++ 25-akpm/net/atm/common.c	Fri Jan 23 15:16:03 2004
@@ -148,7 +148,7 @@ int vcc_create(struct socket *sock, int 
 	sk->sk_state_change = vcc_def_wakeup;
 	sk->sk_write_space = vcc_write_space;
 
-	vcc = atm_sk(sk) = kmalloc(sizeof(*vcc), GFP_KERNEL);
+	vcc = sk->sk_protinfo = kmalloc(sizeof(*vcc), GFP_KERNEL);
 	if (!vcc) {
 		sk_free(sk);
 		return -ENOMEM;

_
