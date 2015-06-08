From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH v2 net-next 1/2] tcp: export tcp_enter_cwr()
Date: Mon,  8 Jun 2015 19:43:39 +0200
Message-ID: <1433785420-4191-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Neal Cardwell <ncardwell@google.com>,
	David Hayes <davihay@ifi.uio.no>,
	Andreas Petlund <apetlund@simula.no>,
	Dave Taht <dave.taht@bufferbloat.net>,
	Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:50289 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751317AbbFHRn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 13:43:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upcoming tcp_cdg uses tcp_enter_cwr() to initiate PRR. Export this
function so that CDG can be compiled as a module.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: David Hayes <davihay@ifi.uio.no>
Cc: Andreas Petlund <apetlund@simula.no>
Cc: Dave Taht <dave.taht@bufferbloat.net>
Cc: Nicolas Kuhn <nicolas.kuhn@telecom-bretagne.eu>
Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
V2: rebase
---
 net/ipv4/tcp_input.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 15c4536..d4f76ab 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2552,6 +2552,7 @@ void tcp_enter_cwr(struct sock *sk)
 		tcp_set_ca_state(sk, TCP_CA_CWR);
 	}
 }
+EXPORT_SYMBOL(tcp_enter_cwr);
 
 static void tcp_try_keep_open(struct sock *sk)
 {
-- 
2.1.0
