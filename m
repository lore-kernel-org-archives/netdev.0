From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 2/3][v2] tcp: fix ICMP-RTO war: Change comment concerning lower
 RTO bound
Date: Fri, 29 Jan 2010 23:15:59 +0100
Message-ID: <4B635E1F.1090200@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54515 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755763Ab0A2WQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 17:16:00 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX100C4V4IFDL00@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 29 Jan 2010 23:15:59 +0100 (CET)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id o0TMFxj9019906	for
 <netdev@vger.kernel.org>; Fri, 29 Jan 2010 23:15:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lower bound for TCP's RTO is checked by __tcp_set_rto() now.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28e0296..5866965 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -693,8 +693,8 @@ static inline void tcp_set_rto(struct sock *sk)
 	 *    with correct one. It is exactly, which we pretend to do.
 	 */
 
-	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
-	 * guarantees that rto is higher.
+	/* NOTE: clamping at TCP_RTO_MIN is not required,
+	 * this is now guaranteed by __tcp_set_rto()
 	 */
 	tcp_bound_rto(sk);
 }
-- 
1.6.4.4
