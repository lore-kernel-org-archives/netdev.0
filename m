From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next] tcp: cleanup messy initializer
Date: Fri, 3 Oct 2008 22:14:27 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810032213230.30432@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1615863613-1223061267=:30432"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46098 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbYJCTUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 15:20:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1615863613-1223061267=:30432
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


I'm quite sure that if I give this function in its old format
for you to inspect, you start to wonder what is the type of
demanded or if it's a global variable.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index db1f194..f547b2f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4465,8 +4465,8 @@ static void tcp_new_space(struct sock *sk)
 
 	if (tcp_should_expand_sndbuf(sk)) {
 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
-			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
-		    demanded = max_t(unsigned int, tp->snd_cwnd,
+			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff);
+		int demanded = max_t(unsigned int, tp->snd_cwnd,
 				     tp->reordering + 1);
 		sndmem *= 2 * demanded;
 		if (sndmem > sk->sk_sndbuf)
-- 
1.5.2.2

---696208474-1615863613-1223061267=:30432--
