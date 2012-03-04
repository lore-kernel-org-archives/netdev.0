From: Dmitry Tarnyagin <abi.dmitryt@gmail.com>
Subject: [PATCH] caif-hsi: Set default MTU to 4096
Date: Sun,  4 Mar 2012 19:38:58 +0100
Message-ID: <1330886338-4814-1-git-send-email-abi.dmitryt@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjurbren@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:46921 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754626Ab2CDSis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 13:38:48 -0500
Received: by lahj13 with SMTP id j13so3800705lah.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 10:38:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Default MTU for CAIF HSI was wrongly set to 15 * 4092 bytes.
The patch sets default MTU size to 4096.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index c8afd62..9a66e2a 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1031,7 +1031,7 @@ static void cfhsi_setup(struct net_device *dev)
 	dev->netdev_ops =3D &cfhsi_ops;
 	dev->type =3D ARPHRD_CAIF;
 	dev->flags =3D IFF_POINTOPOINT | IFF_NOARP;
-	dev->mtu =3D CFHSI_MAX_PAYLOAD_SZ;
+	dev->mtu =3D CFHSI_MAX_CAIF_FRAME_SZ;
 	dev->tx_queue_len =3D 0;
 	dev->destructor =3D free_netdev;
 	skb_queue_head_init(&cfhsi->qhead);
--=20
1.7.9
