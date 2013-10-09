From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 02/16] batman-adv: switch to a new packet compatibility version
Date: Wed,  9 Oct 2013 14:40:04 +0200
Message-ID: <1381322418-1349-3-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	=?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@hundeboll.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:45397 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab3JIMkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 08:40:51 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Antonio Quartulli <ordex@autistici.org>

With this change batman-adv is breaking compatibility with
older versions and it is moving to compat-version 15.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/packet.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index a51ccfc..11a22c8 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -48,7 +48,7 @@ enum batadv_subtype {
 };
=20
 /* this file is included by batctl which needs these defines */
-#define BATADV_COMPAT_VERSION 14
+#define BATADV_COMPAT_VERSION 15
=20
 enum batadv_iv_flags {
 	BATADV_NOT_BEST_NEXT_HOP   =3D BIT(3),
--=20
1.8.3.2
