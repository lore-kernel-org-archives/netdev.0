From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] econet: remove compiler warnings
Date: Wed, 26 Jan 2011 11:04:18 +0100
Message-ID: <1296036258.2899.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53747 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab1AZKEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 05:04:22 -0500
Received: by wyb28 with SMTP id 28so743473wyb.19
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 02:04:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/econet/af_econet.c: In function =E2=80=98econet_sendmsg=E2=80=99:
net/econet/af_econet.c:494: warning: label =E2=80=98error=E2=80=99 defi=
ned but not used
net/econet/af_econet.c:268: warning: unused variable =E2=80=98sk=E2=80=99

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/econet/af_econet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index 15dcc1a..0c28263 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -265,13 +265,13 @@ static void ec_tx_done(struct sk_buff *skb, int r=
esult)
 static int econet_sendmsg(struct kiocb *iocb, struct socket *sock,
 			  struct msghdr *msg, size_t len)
 {
-	struct sock *sk =3D sock->sk;
 	struct sockaddr_ec *saddr=3D(struct sockaddr_ec *)msg->msg_name;
 	struct net_device *dev;
 	struct ec_addr addr;
 	int err;
 	unsigned char port, cb;
 #if defined(CONFIG_ECONET_AUNUDP) || defined(CONFIG_ECONET_NATIVE)
+	struct sock *sk =3D sock->sk;
 	struct sk_buff *skb;
 	struct ec_cb *eb;
 #endif
@@ -488,10 +488,10 @@ static int econet_sendmsg(struct kiocb *iocb, str=
uct socket *sock,
=20
 error_free_buf:
 	vfree(userbuf);
+error:
 #else
 	err =3D -EPROTOTYPE;
 #endif
-	error:
 	mutex_unlock(&econet_mutex);
=20
 	return err;


