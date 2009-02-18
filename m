From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: remove obsoleted comment about different passes
Date: Wed, 18 Feb 2009 19:50:20 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0902181937470.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1596073007-1234979420=:31742"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51190 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbZBRRuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 12:50:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1596073007-1234979420=:31742
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


This is obsolete since the passes got combined.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dda42f0..da2c3b8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2023,7 +2023,6 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		last_lost = tp->snd_una;
 	}
 
-	/* First pass: retransmit lost packets. */
 	tcp_for_write_queue_from(skb, sk) {
 		__u8 sacked = TCP_SKB_CB(skb)->sacked;
 
-- 
1.5.2.2

---696208474-1596073007-1234979420=:31742--
