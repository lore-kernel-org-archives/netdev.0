From: akpm@osdl.org
Subject: [patch 2/3] gcc-3.5: af_packet
Date: Thu, 5 Feb 2004 21:36:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402060536.i165a0N01679@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Fix illegal lvalue with gcc-3.5



---

 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/packet/af_packet.c~gcc-35-packet net/packet/af_packet.c
--- 25/net/packet/af_packet.c~gcc-35-packet	2004-01-25 13:18:18.000000000 -0800
+++ 25-akpm/net/packet/af_packet.c	2004-01-25 13:18:40.000000000 -0800
@@ -961,7 +961,7 @@ static int packet_create(struct socket *
 	sock_init_data(sock,sk);
 	sk_set_owner(sk, THIS_MODULE);
 
-	po = pkt_sk(sk) = kmalloc(sizeof(*po), GFP_KERNEL);
+	po = sk->sk_protinfo = kmalloc(sizeof(*po), GFP_KERNEL);
 	if (!po)
 		goto out_free;
 	memset(po, 0, sizeof(*po));

_
