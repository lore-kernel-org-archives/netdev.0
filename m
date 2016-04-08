From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/5] ethtool: Add support for toggling any of the
 GSO offloads
Date: Fri, 08 Apr 2016 16:33:11 -0400
Message-ID: <20160408203311.12838.84402.stgit@ahduyck-xeon-server>
References: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34045 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758807AbcDHUdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:33:16 -0400
Received: by mail-pf0-f174.google.com with SMTP id c20so82105336pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 13:33:15 -0700 (PDT)
In-Reply-To: <20160408203013.12838.63429.stgit@ahduyck-xeon-server>
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
