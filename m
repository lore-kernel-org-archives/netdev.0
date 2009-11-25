From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] don't wrap mlx4_remove_one in __devexit_p
Date: Wed, 25 Nov 2009 10:23:31 +0100
Message-ID: <1259141011-9567-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <4B0CF685.6060208@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Yang Hongyang <yanghy@cn.fujitsu.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eli Cohen <eli@mellanox.co.il>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Franco Fichtner <franco@lastsummer.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758463AbZKYJ3K@vger.kernel.org>
In-Reply-To: <4B0CF685.6060208@lastsummer.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function mlx4_remove_one is defined in .text, so there is no need t=
o
wrap it with __devexit_p.

While at it add a trailing comma to the section initializer.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: Roland Dreier <rolandd@cisco.com>
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Cc: Yang Hongyang <yanghy@cn.fujitsu.com>
Cc: Jack Morgenstein <jackm@dev.mellanox.co.il>
Cc: Eli Cohen <eli@mellanox.co.il>
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org
Cc: Franco Fichtner <franco@lastsummer.de>
---
 drivers/net/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 291a505..acc2878 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1293,7 +1293,7 @@ static struct pci_driver mlx4_driver =3D {
 	.name		=3D DRV_NAME,
 	.id_table	=3D mlx4_pci_table,
 	.probe		=3D mlx4_init_one,
-	.remove		=3D __devexit_p(mlx4_remove_one)
+	.remove		=3D mlx4_remove_one,
 };
=20
 static int __init mlx4_verify_params(void)
