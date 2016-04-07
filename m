From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 02/11] ethtool: Add support for toggling any of the GSO
 offloads
Date: Thu, 07 Apr 2016 18:32:05 -0400
Message-ID: <20160407223205.11142.79452.stgit@ahduyck-xeon-server>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36585 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251AbcDGWcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 18:32:09 -0400
Received: by mail-pa0-f53.google.com with SMTP id bx7so46396903pad.3
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 15:32:08 -0700 (PDT)
In-Reply-To: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The strings were missing for several of the GSO offloads that are
available.  This patch provides the missing strings so that we can toggle
or query any of them via the ethtool command.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/ethtool.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f426c5ad6149..6a7f99661c2f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -82,9 +82,11 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
+	[NETIF_F_GSO_GRE_CSUM_BIT] =	 "tx-gre-csum-segmentation",
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
+	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CRC_BIT] =        "tx-checksum-sctp",
