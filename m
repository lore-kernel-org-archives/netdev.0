From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 09/12] net: Remove references to NETIF_F_UFO from
 ethtool.
Date: Wed, 05 Jul 2017 16:06:00 +0100 (WEST)
Message-ID: <20170705.160600.454773693772190224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751765AbdGEPGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:06:05 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id D7D34126C97F3
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:06:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is going away.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/ethtool.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2..46f717a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -76,7 +76,6 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_LRO_BIT] =              "rx-lro",
 
 	[NETIF_F_TSO_BIT] =              "tx-tcp-segmentation",
-	[NETIF_F_UFO_BIT] =              "tx-udp-fragmentation",
 	[NETIF_F_GSO_ROBUST_BIT] =       "tx-gso-robust",
 	[NETIF_F_TSO_ECN_BIT] =          "tx-tcp-ecn-segmentation",
 	[NETIF_F_TSO_MANGLEID_BIT] =	 "tx-tcp-mangleid-segmentation",
@@ -299,9 +298,6 @@ static netdev_features_t ethtool_get_feature_mask(u32 eth_cmd)
 	case ETHTOOL_GTSO:
 	case ETHTOOL_STSO:
 		return NETIF_F_ALL_TSO;
-	case ETHTOOL_GUFO:
-	case ETHTOOL_SUFO:
-		return NETIF_F_UFO;
 	case ETHTOOL_GGSO:
 	case ETHTOOL_SGSO:
 		return NETIF_F_GSO;
@@ -2563,7 +2559,6 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GPHYSTATS:
 	case ETHTOOL_GTSO:
 	case ETHTOOL_GPERMADDR:
-	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GGRO:
 	case ETHTOOL_GFLAGS:
@@ -2731,7 +2726,6 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCSUM:
 	case ETHTOOL_GSG:
 	case ETHTOOL_GTSO:
-	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GGRO:
 		rc = ethtool_get_one_feature(dev, useraddr, ethcmd);
@@ -2740,7 +2734,6 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SRXCSUM:
 	case ETHTOOL_SSG:
 	case ETHTOOL_STSO:
-	case ETHTOOL_SUFO:
 	case ETHTOOL_SGSO:
 	case ETHTOOL_SGRO:
 		rc = ethtool_set_one_feature(dev, useraddr, ethcmd);
-- 
2.9.4
