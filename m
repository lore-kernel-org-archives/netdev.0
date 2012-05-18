From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Remove netdevice ec_ptr, no longer used.
Date: Fri, 18 May 2012 01:40:13 -0400 (EDT)
Message-ID: <20120518.014013.149811887006702108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755054Ab2ERFkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 01:40:15 -0400
Received: from localhost (cpe-66-108-119-99.nyc.res.rr.com [66.108.119.99])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q4I5eEAJ025099
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 17 May 2012 22:40:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ECONET is gone, thus this can be deleted as well.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0f6f22..9c710bd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1155,7 +1155,6 @@ struct net_device {
 	struct in_device __rcu	*ip_ptr;	/* IPv4 specific data	*/
 	struct dn_dev __rcu     *dn_ptr;        /* DECnet specific data */
 	struct inet6_dev __rcu	*ip6_ptr;       /* IPv6 specific data */
-	void			*ec_ptr;	/* Econet specific data	*/
 	void			*ax25_ptr;	/* AX.25 specific data */
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
-- 
1.7.10.1
