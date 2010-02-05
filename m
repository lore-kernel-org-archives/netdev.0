From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: bridge: Remove unused age_list
Date: Fri, 5 Feb 2010 14:31:03 +1100
Message-ID: <20100205033103.GA11224@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47848 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754180Ab0BEEk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 23:40:58 -0500
Received: from gondolin.me.apana.org.au ([192.168.0.6])
	by arnor.apana.org.au with esmtp (Exim 4.63 #1 (Debian))
	id 1NdG00-0002Az-If
	for <netdev@vger.kernel.org>; Fri, 05 Feb 2010 15:40:56 +1100
Received: from herbert by gondolin.me.apana.org.au with local (Exim 4.69)
	(envelope-from <herbert@gondor.apana.org.au>)
	id 1NdG00-00034V-A2
	for netdev@vger.kernel.org; Fri, 05 Feb 2010 15:40:56 +1100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

bridge: Remove unused age_list

This patch removes the unused age_list member from the net_bridge
structure.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index a2cbe61..35e80e9 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -206,8 +206,6 @@ static struct net_device *new_bridge_dev(struct net *net, const char *name)
 
 	br_netfilter_rtable_init(br);
 
-	INIT_LIST_HEAD(&br->age_list);
-
 	br_stp_timer_init(br);
 
 	return dev;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2114e45..1f0c4f4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -93,7 +93,6 @@ struct net_bridge
 	struct net_device		*dev;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-	struct list_head		age_list;
 	unsigned long			feature_mask;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct rtable 			fake_rtable;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
