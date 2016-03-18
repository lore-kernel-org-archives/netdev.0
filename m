From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 6/9] ethtool: Add support for toggling any of the GSO
 offloads
Date: Fri, 18 Mar 2016 16:25:16 -0700
Message-ID: <20160318232516.14955.2907.stgit@localhost.localdomain>
References: <20160318230945.14955.63211.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: ecree@solarflare.com, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33494 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbcCRXZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:25:18 -0400
Received: by mail-pf0-f178.google.com with SMTP id 4so55279406pfd.0
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 16:25:17 -0700 (PDT)
In-Reply-To: <20160318230945.14955.63211.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The strings were missing for several of the GSO offloads that are
available.  This patch provides the missing strings so that we can toggle
or query any of them via the ethtool command.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/ethtool.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2966cd0d7c93..b3c39d531469 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -82,9 +82,12 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
+	[NETIF_F_GSO_GRE_CSUM_BIT] =	 "tx-gre-csum-segmentation",
 	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
 	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
+	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
+	[NETIF_F_GSO_TUNNEL_REMCSUM_BIT] = "tx-remcsum-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CRC_BIT] =        "tx-checksum-sctp",
