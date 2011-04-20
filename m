From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] staging: octeon-ethernet: remove .get_sg, etc. ethtool_ops
Date: Wed, 20 Apr 2011 16:25:53 +0200 (CEST)
Message-ID: <20110420142553.D497813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55974 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110Ab1DTOZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 10:25:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/staging/octeon/ethernet-mdio.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/o=
cteon/ethernet-mdio.c
index 10a82ef..8a11ffc 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -91,8 +91,6 @@ const struct ethtool_ops cvm_oct_ethtool_ops =3D {
 	.set_settings =3D cvm_oct_set_settings,
 	.nway_reset =3D cvm_oct_nway_reset,
 	.get_link =3D ethtool_op_get_link,
-	.get_sg =3D ethtool_op_get_sg,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
 };
=20
 /**
--=20
1.7.2.5

