From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 10/10] staging: vt6656: inherit addr_assign_type along with dev_addr
Date: Fri, 23 Aug 2013 11:35:13 +0200
Message-ID: <1377250513-3662-11-git-send-email-bjorn@mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org,
	Forest Bond <forest@alittletooquiet.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40839 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590Ab3HWJjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:39:41 -0400
In-Reply-To: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Forest Bond <forest@alittletooquiet.net>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/staging/vt6656/hostap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/vt6656/hostap.c b/drivers/staging/vt6656/h=
ostap.c
index c699a30..3ddef9d 100644
--- a/drivers/staging/vt6656/hostap.c
+++ b/drivers/staging/vt6656/hostap.c
@@ -77,7 +77,7 @@ static int hostap_enable_hostapd(struct vnt_private *=
pDevice, int rtnl_locked)
=20
     apdev_priv =3D netdev_priv(pDevice->apdev);
     *apdev_priv =3D *pDevice;
-	memcpy(pDevice->apdev->dev_addr, dev->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(pDevice->apdev, dev);
=20
 	pDevice->apdev->netdev_ops =3D &apdev_netdev_ops;
=20
--=20
1.7.10.4
