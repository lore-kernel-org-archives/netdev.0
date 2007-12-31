From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/3] [TCP]: Remove unnecessary local variable
Date: Mon, 31 Dec 2007 16:21:47 +0200
Message-ID: <11991109071896-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11991109072239-git-send-email-ilpo.jarvinen@helsinki.fi> <11991109072164-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50023 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbXLaOVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 09:21:48 -0500
In-Reply-To: <11991109072164-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b3110fc..f6d279a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -995,9 +995,8 @@ unsigned int tcp_current_mss(struct sock *sk, int l=
arge_allowed)
 static void tcp_cwnd_validate(struct sock *sk)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
-	__u32 packets_out =3D tp->packets_out;
=20
-	if (packets_out >=3D tp->snd_cwnd) {
+	if (tp->packets_out >=3D tp->snd_cwnd) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used =3D 0;
 		tp->snd_cwnd_stamp =3D tcp_time_stamp;
--=20
1.5.0.6

