From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: batman-adv: remove rx_csum ethtool_ops
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)
Message-ID: <20110419104320.0675D1389B@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marek Lindner <lindner_marek@yahoo.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Sven Eckelmann <sven@narfation.org>,
	b.a.t.m.a.n@lists.open-mesh.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46857 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753487Ab1DSKnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 06:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/batman-adv/soft-interface.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 1f6f756..f4d80ad 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -43,8 +43,6 @@ static void bat_get_drvinfo(struct net_device *dev,
 static u32 bat_get_msglevel(struct net_device *dev);
 static void bat_set_msglevel(struct net_device *dev, u32 value);
 static u32 bat_get_link(struct net_device *dev);
-static u32 bat_get_rx_csum(struct net_device *dev);
-static int bat_set_rx_csum(struct net_device *dev, u32 data);
=20
 static const struct ethtool_ops bat_ethtool_ops =3D {
 	.get_settings =3D bat_get_settings,
@@ -52,8 +50,6 @@ static const struct ethtool_ops bat_ethtool_ops =3D {
 	.get_msglevel =3D bat_get_msglevel,
 	.set_msglevel =3D bat_set_msglevel,
 	.get_link =3D bat_get_link,
-	.get_rx_csum =3D bat_get_rx_csum,
-	.set_rx_csum =3D bat_set_rx_csum
 };
=20
 int my_skb_head_push(struct sk_buff *skb, unsigned int len)
@@ -736,12 +732,3 @@ static u32 bat_get_link(struct net_device *dev)
 	return 1;
 }
=20
-static u32 bat_get_rx_csum(struct net_device *dev)
-{
-	return 0;
-}
-
-static int bat_set_rx_csum(struct net_device *dev, u32 data)
-{
-	return -EOPNOTSUPP;
-}
--=20
1.7.2.5

