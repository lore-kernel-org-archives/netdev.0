From: Franco Fichtner <franco@lastsummer.de>
Subject: [PATCH net-next] ethtool: bring back missing comma in netdev_features_strings
Date: Thu, 12 May 2011 10:05:58 +0200
Message-ID: <4DCB94E6.2020407@lastsummer.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020704020909050808030804"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:42920 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab1ELIao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 04:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020704020909050808030804
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all,

I found this while skimming through recent net-next patches.
I'm not quite sure if the padding in this struct is correct now.


Franco

--------------020704020909050808030804
Content-Type: text/x-patch;
 name="0001-ethtool-bring-back-missing-comma-in-netdev_features_.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ethtool-bring-back-missing-comma-in-netdev_features_.pa";
 filename*1="tch"

>From c62ca7bb87baad78e285dc0e698e792051d8fa87 Mon Sep 17 00:00:00 2001
From: Franco Fichtner <franco@lastsummer.de>
Date: Wed, 11 May 2011 09:49:08 +0200
Subject: [PATCH net-next] ethtool: bring back missing comma in netdev_features_strings

The issue was introduced in commit eed2a12f1ed9aabf.

Signed-off-by: Franco Fichtner <franco@lastsummer.de>
---
 net/core/ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b6f4058..b8c2b10 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -361,7 +361,7 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
 	/* NETIF_F_RXHASH */          "rx-hashing",
 	/* NETIF_F_RXCSUM */          "rx-checksum",
-	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
+	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
 	/* NETIF_F_LOOPBACK */        "loopback",
 };
 
-- 
1.7.3.2.493.g0b0cd


--------------020704020909050808030804--
