From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] TCP build fix
Date: Fri, 11 Nov 2005 04:43:47 -0500
Message-ID: <20051111094347.GA10876@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932321AbVKKJnx@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	davem@davemloft.net, shemminger@osdl.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Recent TCP changes broke the build.

Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 4376814..b7d296a 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -236,7 +236,7 @@ static void tcp_vegas_cong_avoid(struct 
 			/* We don't have enough RTT samples to do the Vegas
 			 * calculation, so we'll behave like Reno.
 			 */
-			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, cnt);
+			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
 		} else {
 			u32 rtt, target_cwnd, diff;
 
