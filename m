From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ping: cleanups ping_v4_unhash()
Date: Mon, 23 May 2011 10:23:00 +0200
Message-ID: <1306138981.2869.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64718 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab1EWIXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 04:23:04 -0400
Received: by wwa36 with SMTP id 36so5929285wwa.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 01:23:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/ping.c: In function =E2=80=98ping_v4_unhash=E2=80=99:
net/ipv4/ping.c:140:28: warning: variable =E2=80=98hslot=E2=80=99 set b=
ut not used

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Vasiliy Kulikov <segoon@openwall.com>
---
 net/ipv4/ping.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 1f3bb11..9aaa671 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -137,9 +137,6 @@ static void ping_v4_unhash(struct sock *sk)
 	struct inet_sock *isk =3D inet_sk(sk);
 	pr_debug("ping_v4_unhash(isk=3D%p,isk->num=3D%u)\n", isk, isk->inet_n=
um);
 	if (sk_hashed(sk)) {
-		struct hlist_nulls_head *hslot;
-
-		hslot =3D ping_hashslot(&ping_table, sock_net(sk), isk->inet_num);
 		write_lock_bh(&ping_table.lock);
 		hlist_nulls_del(&sk->sk_nulls_node);
 		sock_put(sk);


