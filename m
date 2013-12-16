From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/10] ipv4: remove unused function
Date: Mon, 16 Dec 2013 10:38:30 -0800
Message-ID: <20131216103830.37613ce0@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:37991 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab3LPTkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:23 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so5918142pbb.2
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:23 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inetpeer_invalidate_family defined but never used

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/inetpeer.h	2013-12-12 11:48:17.245852289 -0800
+++ b/include/net/inetpeer.h	2013-12-12 11:56:49.397876085 -0800
@@ -163,7 +163,6 @@ void inet_putpeer(struct inet_peer *p);
 bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout);
 
 void inetpeer_invalidate_tree(struct inet_peer_base *);
-void inetpeer_invalidate_family(int family);
 
 /*
  * temporary check to make sure we dont access rid, ip_id_count, tcp_ts,
--- a/net/ipv4/inetpeer.c	2013-12-12 11:48:17.245852289 -0800
+++ b/net/ipv4/inetpeer.c	2013-12-12 11:56:49.397876085 -0800
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
