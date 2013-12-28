From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv4: remove unused function
Date: Sat, 28 Dec 2013 11:08:22 -0800
Message-ID: <20131228110822.1ce0b9cd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56634 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594Ab3L1TI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 14:08:27 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so10301665pab.25
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 11:08:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer_invalidate_family defined but never used

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 include/net/inetpeer.h |    1 -
 net/ipv4/inetpeer.c    |    7 -------
 2 files changed, 8 deletions(-)

--- a/include/net/inetpeer.h	2013-12-24 15:15:26.785740972 -0800
+++ b/include/net/inetpeer.h	2013-12-24 15:15:59.729298216 -0800
@@ -163,7 +163,6 @@ void inet_putpeer(struct inet_peer *p);
 bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
 void inetpeer_invalidate_tree(struct inet_peer_base *);
-void inetpeer_invalidate_family(int family);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
--- a/net/ipv4/inetpeer.c	2013-12-24 15:15:26.785740972 -0800
+++ b/net/ipv4/inetpeer.c	2013-12-24 15:15:59.733298164 -0800
@@ -109,13 +109,6 @@ static inline void flush_check(struct in
 	}
 }
 
-void inetpeer_invalidate_family(int family)
-{
-	atomic_t *fp = inetpeer_seq_ptr(family);
-
-	atomic_inc(fp);
-}
-
 #define PEER_MAXDEPTH 40 /* sufficient for about 2^27 nodes */
 
 /* Exported for sysctl_net_ipv4.  */
