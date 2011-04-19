From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] Staging: convert hv network driver to hw_features
Date: Tue, 19 Apr 2011 12:43:20 +0200 (CEST)
Message-ID: <20110419104320.0C91E13A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Hank Janssen <hjanssen@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Abhishek Kane <v-abkane@microsoft.com>,
	devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46858 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754639Ab1DSKnV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 06:43:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/staging/hv/netvsc_drv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvs=
c_drv.c
index 3397356..aaa8188 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -317,8 +317,6 @@ static void netvsc_get_drvinfo(struct net_device *n=
et,
=20
 static const struct ethtool_ops ethtool_ops =3D {
 	.get_drvinfo	=3D netvsc_get_drvinfo,
-	.get_sg		=3D ethtool_op_get_sg,
-	.set_sg		=3D ethtool_op_set_sg,
 	.get_link	=3D ethtool_op_get_link,
 };
=20
@@ -406,6 +404,7 @@ static int netvsc_probe(struct device *device)
 	net->netdev_ops =3D &device_ops;
=20
 	/* TODO: Add GSO and Checksum offload */
+	net->hw_features =3D NETIF_F_SG;
 	net->features =3D NETIF_F_SG;
=20
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
--=20
1.7.2.5

