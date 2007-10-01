From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/4] [TCP]: fix comments that got messed up during code move
Date: Mon,  1 Oct 2007 15:29:42 +0300
Message-ID: <11912417843258-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417843256-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51017 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbXJAM3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 08:29:45 -0400
In-Reply-To: <11912417843256-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2286361..135f046 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1467,8 +1467,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	return flag;
 }
=20
-/* F-RTO can only be used if TCP has never retransmitted anything othe=
r than
- * head (SACK enhanced variant from Appendix B of RFC4138 is more robu=
st here)
+/* If we receive more dupacks than we expected counting segments
+ * in assumption of absent reordering, interpret this as reordering.
+ * The only another reason could be bug in receiver TCP.
  */
 static void tcp_check_reno_reordering(struct sock *sk, const int adden=
d)
 {
@@ -1516,6 +1517,9 @@ static inline void tcp_reset_reno_sack(struct tcp=
_sock *tp)
 	tp->sacked_out =3D 0;
 }
=20
+/* F-RTO can only be used if TCP has never retransmitted anything othe=
r than
+ * head (SACK enhanced variant from Appendix B of RFC4138 is more robu=
st here)
+ */
 int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
--=20
1.5.0.6

