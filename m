From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 08/15] tcp: remove obsolete validity concern
Date: Sat, 20 Sep 2008 20:52:26 +0300
Message-ID: <1221933153-11874-9-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49080 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbYITRwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:38 -0400
In-Reply-To: <1221933153-11874-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2cec9b2..8d4859a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2089,10 +2089,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	if (!tcp_can_forward_retransmit(sk))
 		return;
=20
-	/* If nothing is SACKed, highest_sack in the loop won't be valid */
-	if (!tp->sacked_out)
-		return;
-
 	if (tp->forward_skb_hint)
 		skb =3D tp->forward_skb_hint;
 	else
--=20
1.5.2.2

