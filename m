From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ethtool: fix IPV6 checksum feature name string
Date: Tue, 17 May 2011 22:40:15 +0200 (CEST)
Message-ID: <20110517204015.2F4C013A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60804 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab1EQUkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 16:40:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
This is against net-next but shoud go also to net.

 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index ed6c0d4..59255c1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -355,7 +355,7 @@ static const char netdev_features_strings[ETHTOOL_D=
EV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_IP_CSUM */         "tx-checksum-ipv4",
 	/* NETIF_F_NO_CSUM */         "tx-checksum-unneeded",
 	/* NETIF_F_HW_CSUM */         "tx-checksum-ip-generic",
-	/* NETIF_F_IPV6_CSUM */       "tx_checksum-ipv6",
+	/* NETIF_F_IPV6_CSUM */       "tx-checksum-ipv6",
 	/* NETIF_F_HIGHDMA */         "highdma",
 	/* NETIF_F_FRAGLIST */        "tx-scatter-gather-fraglist",
 	/* NETIF_F_HW_VLAN_TX */      "tx-vlan-hw-insert",
--=20
1.7.2.5

