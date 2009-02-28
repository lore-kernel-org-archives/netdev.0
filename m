From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 15/17] tcp: kill pointless if () in sack_remove
Date: Sat, 28 Feb 2009 16:44:40 +0200
Message-ID: <12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56777 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbZB1Ooy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:54 -0500
In-Reply-To: <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 464c8a4..071917d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4248,8 +4248,7 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 		this_sack++;
 		sp++;
 	}
-	if (num_sacks !=3D tp->rx_opt.num_sacks)
-		tp->rx_opt.num_sacks =3D num_sacks;
+	tp->rx_opt.num_sacks =3D num_sacks;
 }
=20
 /* This one checks to see if we can put data from the
--=20
1.5.6.5

