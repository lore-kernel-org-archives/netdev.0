From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Remove invalid offloads
Date: Fri,  8 Apr 2011 14:38:46 +0200 (CEST)
Message-ID: <20110408123846.D947E13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Li Yang <leoli@freescale.com>, linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40592 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234Ab1DHMis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 08:38:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove offload changing ethtool ops which drivers don't really support:

 - fs_enet
 - ucc_geth

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/fs_enet/fs_enet-main.c |    2 --
 drivers/net/ucc_geth_ethtool.c     |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/f=
s_enet-main.c
index 24cb953..a938894 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -956,8 +956,6 @@ static const struct ethtool_ops fs_ethtool_ops =3D =
{
 	.get_link =3D ethtool_op_get_link,
 	.get_msglevel =3D fs_get_msglevel,
 	.set_msglevel =3D fs_set_msglevel,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,	/* local! */
-	.set_sg =3D ethtool_op_set_sg,
 	.get_regs =3D fs_get_regs,
 };
=20
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_etht=
ool.c
index 6f92e48..537fbc0 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -410,7 +410,6 @@ static const struct ethtool_ops uec_ethtool_ops =3D=
 {
 	.set_ringparam          =3D uec_set_ringparam,
 	.get_pauseparam         =3D uec_get_pauseparam,
 	.set_pauseparam         =3D uec_set_pauseparam,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_sset_count		=3D uec_get_sset_count,
 	.get_strings            =3D uec_get_strings,
 	.get_ethtool_stats      =3D uec_get_ethtool_stats,
--=20
1.7.2.5

