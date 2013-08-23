From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 08/10] net: libertas: inherit addr_assign_type along with dev_addr
Date: Fri, 23 Aug 2013 11:35:11 +0200
Message-ID: <1377250513-3662-9-git-send-email-bjorn@mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40799 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215Ab3HWJg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:36:26 -0400
In-Reply-To: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: "John W. Linville" <linville@tuxdriver.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/wireless/libertas/mesh.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireles=
s/libertas/mesh.c
index efae07e..6fef746 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -1017,7 +1017,7 @@ static int lbs_add_mesh(struct lbs_private *priv)
=20
 	mesh_dev->netdev_ops =3D &mesh_netdev_ops;
 	mesh_dev->ethtool_ops =3D &lbs_ethtool_ops;
-	memcpy(mesh_dev->dev_addr, priv->dev->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(mesh_dev, priv->dev);
=20
 	SET_NETDEV_DEV(priv->mesh_dev, priv->dev->dev.parent);
=20
--=20
1.7.10.4
