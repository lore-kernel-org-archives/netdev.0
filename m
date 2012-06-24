From: sjur.brandeland@stericsson.com
Subject: [net 1/3] caif: Clear shutdown mask to zero at reconnect.
Date: Sun, 24 Jun 2012 23:01:36 +0200
Message-ID: <1340571698-17892-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:60193 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159Ab2FXVBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2012 17:01:47 -0400
Received: by lbbgm6 with SMTP id gm6so5685469lbb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jun 2012 14:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Clear caif sockets's shutdown mask at (re)connect.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index fb89443..78f1cda 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -220,6 +220,7 @@ static void caif_ctrl_cb(struct cflayer *layr,
 						cfsk_hold, cfsk_put);
 		cf_sk->sk.sk_state =3D CAIF_CONNECTED;
 		set_tx_flow_on(cf_sk);
+		cf_sk->sk.sk_shutdown =3D 0;
 		cf_sk->sk.sk_state_change(&cf_sk->sk);
 		break;
=20
--=20
1.7.5.4
