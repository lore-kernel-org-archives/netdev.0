From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] staging: octeon-ethernet: remove .get_sg, etc. ethtool_ops
Date: Wed, 20 Apr 2011 18:27:09 +0200 (CEST)
Message-ID: <20110420162709.2FB1713909@rere.qmqm.pl>
References: <20110420143612.GA22661@suse.de> <20110420142553.D497813909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:52397 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821Ab1DTQ1K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 12:27:10 -0400
In-Reply-To: <20110420143612.GA22661@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver sets .get_sg and .get_tx_csum ethtool_ops to their default
values anyway. Those fields are deprecated, starting in 2.6.39.

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

