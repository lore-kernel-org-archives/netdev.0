From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 2/3] [TCP]: Urgent parameter effect can be simplified.
Date: Thu,  3 Jan 2008 13:00:06 +0200
Message-ID: <11993580071646-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37116 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbYACLAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 06:00:10 -0500
In-Reply-To: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f6d279a..6c7cd0a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2488,7 +2488,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, in=
t urgent)
 	 * end to send an ack.  Don't queue or clone SKB, just
 	 * send it.
 	 */
-	TCP_SKB_CB(skb)->seq =3D urgent ? tp->snd_una : tp->snd_una - 1;
+	TCP_SKB_CB(skb)->seq =3D tp->snd_una - !urgent;
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
--=20
1.5.0.6

