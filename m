From: akpm@osdl.org
Subject: [patch 1/3] gcc-3.5: netlink
Date: Thu, 5 Feb 2004 21:35:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402060535.i165ZsN01650@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Fix illegal lvalue with gcc-3.5



---

 net/netlink/af_netlink.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/netlink/af_netlink.c~gcc-35-netlink net/netlink/af_netlink.c
--- 25/net/netlink/af_netlink.c~gcc-35-netlink	2004-01-25 13:16:12.000000000 -0800
+++ 25-akpm/net/netlink/af_netlink.c	2004-01-25 13:18:09.000000000 -0800
@@ -230,7 +230,7 @@ static int netlink_create(struct socket 
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	nlk = nlk_sk(sk) = kmalloc(sizeof(*nlk), GFP_KERNEL);
+	nlk = sk->sk_protinfo = kmalloc(sizeof(*nlk), GFP_KERNEL);
 	if (!nlk) {
 		sk_free(sk);
 		return -ENOMEM;

_
