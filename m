From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: ethtool: fix coding style
Date: Thu, 17 Nov 2011 01:32:03 +0100 (CET)
Message-ID: <8c950d750a6b1d491cb321f024e2bca9f238ab9c.1321489851.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:39020 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754592Ab1KQAcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 19:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing spaces around multiplication operator.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d2eff9e..31b0b7f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -87,13 +87,14 @@ static int ethtool_get_features(struct net_device *=
dev, void __user *useraddr)
 	int i;
=20
 	/* in case feature bits run out again */
-	BUILD_BUG_ON(ETHTOOL_DEV_FEATURE_WORDS*sizeof(u32) > sizeof(netdev_fe=
atures_t));
+	BUILD_BUG_ON(ETHTOOL_DEV_FEATURE_WORDS * sizeof(u32) > sizeof(netdev_=
features_t));
=20
 	for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
-		features[i].available =3D (u32)(dev->hw_features >> (32*i));
-		features[i].requested =3D (u32)(dev->wanted_features >> (32*i));
-		features[i].active =3D (u32)(dev->features >> (32*i));
-		features[i].never_changed =3D (u32)(NETIF_F_NEVER_CHANGE >> (32*i));
+		features[i].available =3D (u32)(dev->hw_features >> (32 * i));
+		features[i].requested =3D (u32)(dev->wanted_features >> (32 * i));
+		features[i].active =3D (u32)(dev->features >> (32 * i));
+		features[i].never_changed =3D
+			(u32)(NETIF_F_NEVER_CHANGE >> (32 * i));
 	}
=20
 	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
@@ -130,8 +131,8 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
 		return -EFAULT;
=20
 	for (i =3D 0; i < ETHTOOL_DEV_FEATURE_WORDS; ++i) {
-		valid |=3D (netdev_features_t)features[i].valid << (32*i);
-		wanted |=3D (netdev_features_t)features[i].requested << (32*i);
+		valid |=3D (netdev_features_t)features[i].valid << (32 * i);
+		wanted |=3D (netdev_features_t)features[i].requested << (32 * i);
 	}
=20
 	if (valid & ~NETIF_F_ETHTOOL_BITS)
--=20
1.7.7.1
