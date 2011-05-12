From: franco@lastsummer.de
Subject: =?ISO-8859-1?Q?[PATCH RESEND net-nex?=  =?ISO-8859-1?Q?t] ethtool: bring bac?=  =?ISO-8859-1?Q?k missing comma in ne?=  =?ISO-8859-1?Q?tdev_features_strings?=
Date: Thu, 12 May 2011 18:42:04 +0200 (CEST)
Message-ID: <20110512164204.EC8391220061@host64.kissl.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, mirqus@gmail.com, franco@lastsummer.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:37004 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757910Ab1ELQmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 12:42:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue was introduced in commit eed2a12f1ed9aabf.

Signed-off-by: Franco Fichtner <franco@lastsummer.de>
---
 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b6f4058..b8c2b10 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -361,7 +361,7 @@ static const char
netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
 	/* NETIF_F_RXHASH */          "rx-hashing",
 	/* NETIF_F_RXCSUM */          "rx-checksum",
-	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
+	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
 	/* NETIF_F_LOOPBACK */        "loopback",
 };

--
1.7.3.2.493.g0b0cd


