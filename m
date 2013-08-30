From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 net-next 8/9] net: libertas: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:51 +0200
Message-ID: <1377878932-26881-9-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Acked-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
