From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH] net: Corrected spelling error heurestics->heuristics
Date: Tue, 27 Oct 2009 14:27:21 +0100
Message-ID: <4AE6F539.1020107@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linux-kernel@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752223AbZJ0OLt@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corrected a spelling error in a function name.

Signed-off-by: Andreas Petlund <apetlund@simula.no>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d86784b..a0c3700 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2300,7 +2300,7 @@ static inline int tcp_fackets_out(struct tcp_sock *tp)
  * they differ. Since neither occurs due to loss, TCP should really
  * ignore them.
  */
-static inline int tcp_dupack_heurestics(struct tcp_sock *tp)
+static inline int tcp_dupack_heuristics(struct tcp_sock *tp)
 {
 	return tcp_is_fack(tp) ? tp->fackets_out : tp->sacked_out + 1;
 }
@@ -2425,7 +2425,7 @@ static int tcp_time_to_recover(struct sock *sk)
 		return 1;
 
 	/* Not-A-Trick#2 : Classic rule... */
-	if (tcp_dupack_heurestics(tp) > tp->reordering)
+	if (tcp_dupack_heuristics(tp) > tp->reordering)
 		return 1;
 
 	/* Trick#3 : when we use RFC2988 timer restart, fast
-- 
1.6.0.4
