From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 10/38] don't wrap mlx4_remove_one in __devexit_p
Date: Tue, 24 Nov 2009 22:07:05 +0100
Message-ID: <1259096853-18909-10-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1259096853-18909-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-2-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-3-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-4-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-5-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-6-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-7-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-8-git-send-email-u.kleine-koenig@pengutronix.de>
 <1259096853-18909-9-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.co.il>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934194AbZKXVOA@vger.kernel.org>
In-Reply-To: <1259096853-18909-9-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function mlx4_remove_one is defined in .text, so there is no need t=
o
wrap it with __devexit_p.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Roland Dreier <rolandd@cisco.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>
Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>
Cc: Eli Cohen <eli@mellanox.co.il>
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 291a505..a581860 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1293,7 +1293,7 @@ static struct pci_driver mlx4_driver =3D {
 	.name		=3D DRV_NAME,
 	.id_table	=3D mlx4_pci_table,
 	.probe		=3D mlx4_init_one,
-	.remove		=3D __devexit_p(mlx4_remove_one)
+	.remove		=3D mlx4_remove_one
 };
=20
 static int __init mlx4_verify_params(void)
--=20
1.6.5.2
