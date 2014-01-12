From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ipv6: addrconf spelling fixes
Date: Sun, 12 Jan 2014 11:26:32 -0800
Message-ID: <20140112112632.363ef751@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:62175 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbaALT0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 14:26:35 -0500
Received: by mail-pd0-f170.google.com with SMTP id z10so1246214pdj.1
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 11:26:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/ipv6/addrconf.c	2014-01-12 10:30:22.367628654 -0800
+++ b/net/ipv6/addrconf.c	2014-01-12 10:53:06.100102563 -0800
@@ -984,8 +984,8 @@ static void ipv6_del_addr(struct inet6_i
 	 *
 	 * 1) we don't purge prefix here if address was not permanent.
 	 *    prefix is managed by its own lifetime.
-	 * 2) if there're no addresses, delete prefix.
-	 * 3) if there're still other permanent address(es),
+	 * 2) if there are no addresses, delete prefix.
+	 * 3) if there are still other permanent address(es),
 	 *    corresponding prefix is still permanent.
 	 * 4) otherwise, update prefix lifetime to the
 	 *    longest valid lifetime among the corresponding
@@ -1206,7 +1206,7 @@ static int ipv6_get_saddr_eval(struct ne
 		 *       |             d is scope of the destination.
 		 *  B-d  |  \
 		 *       |   \      <- smaller scope is better if
-		 *  B-15 |    \        if scope is enough for destinaion.
+		 *  B-15 |    \        if scope is enough for destination.
 		 *       |             ret = B - scope (-1 <= scope >= d <= 15).
 		 * d-C-1 | /
 		 *       |/         <- greater is better
@@ -2876,7 +2876,7 @@ static int addrconf_notify(struct notifi
 		}
 
 		/*
-		 * MTU falled under IPV6_MIN_MTU.
+		 * if MTU under IPV6_MIN_MTU.
 		 * Stop IPv6 on this interface.
 		 */
 
@@ -3731,7 +3731,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	if (ifa == NULL) {
 		/*
 		 * It would be best to check for !NLM_F_CREATE here but
-		 * userspace alreay relies on not having to provide this.
+		 * userspace already relies on not having to provide this.
 		 */
 		return inet6_addr_add(net, ifm->ifa_index, pfx, peer_pfx,
 				      ifm->ifa_prefixlen, ifa_flags,
