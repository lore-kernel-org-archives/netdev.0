From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 2/3] bnx2: use net_device_stats nowadays available in net_device
Date: Fri, 28 Nov 2008 19:53:37 +0200
Message-ID: <12278948182487-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12278948183224-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46125 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbYK1Rxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 12:53:41 -0500
In-Reply-To: <12278948183224-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/bnx2.c |    2 +-
 drivers/net/bnx2.h |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8f1cd7c..182f241 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6155,7 +6155,7 @@ bnx2_get_stats(struct net_device *dev)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
 	struct statistics_block *stats_blk =3D bp->stats_blk;
-	struct net_device_stats *net_stats =3D &bp->net_stats;
+	struct net_device_stats *net_stats =3D &dev->stats;
=20
 	if (bp->stats_blk =3D=3D NULL) {
 		return net_stats;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 34ca478..0763108 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6872,8 +6872,6 @@ struct bnx2 {
 	int			pm_cap;
 	int			pcix_cap;
=20
-	struct net_device_stats net_stats;
-
 	struct flash_spec	*flash_info;
 	u32			flash_size;
=20
--=20
1.5.2.2

