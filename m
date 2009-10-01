From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 30/34] move virtnet_remove to .devexit.text
Date: Thu,  1 Oct 2009 10:28:34 +0200
Message-ID: <1254385718-14254-30-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20091001082607.GA2181@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Alex Williamson <alex.williamson@hp.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932338AbZJAIaF@vger.kernel.org>
In-Reply-To: <20091001082607.GA2181@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function virtnet_remove is used only wrapped by __devexit_p so defi=
ne
it using __devexit.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Alex Williamson <alex.williamson@hp.com>
Cc: Mark McLoughlin <markmc@redhat.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d445845..8d00976 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -948,7 +948,7 @@ free:
 	return err;
 }
=20
-static void virtnet_remove(struct virtio_device *vdev)
+static void __devexit virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi =3D vdev->priv;
 	struct sk_buff *skb;
--=20
1.6.4.3
