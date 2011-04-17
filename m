From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: benet: convert to hw_features - fixup
Date: Sun, 17 Apr 2011 12:15:47 +0200 (CEST)
Message-ID: <20110417101547.5F75513A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48106 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453Ab1DQKPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove be_set_flags() as it's already covered by hw_features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/benet/be_ethtool.c |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_etht=
ool.c
index 80226e4..ab7ebdd 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -716,18 +716,6 @@ be_read_eeprom(struct net_device *netdev, struct e=
thtool_eeprom *eeprom,
 	return status;
 }
=20
-static int be_set_flags(struct net_device *netdev, u32 data)
-{
-	struct be_adapter *adapter =3D netdev_priv(netdev);
-	int rc =3D -1;
-
-	if (be_multi_rxq(adapter))
-		rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RXHASH |
-				ETH_FLAG_TXVLAN | ETH_FLAG_RXVLAN);
-
-	return rc;
-}
-
 const struct ethtool_ops be_ethtool_ops =3D {
 	.get_settings =3D be_get_settings,
 	.get_drvinfo =3D be_get_drvinfo,
@@ -749,5 +737,4 @@ const struct ethtool_ops be_ethtool_ops =3D {
 	.get_regs =3D be_get_regs,
 	.flash_device =3D be_do_flash,
 	.self_test =3D be_self_test,
-	.set_flags =3D be_set_flags,
 };
--=20
1.7.2.5

