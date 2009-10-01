From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 13/34] don't use __devexit_p to wrap meth_remove
Date: Thu,  1 Oct 2009 10:28:17 +0200
Message-ID: <1254385718-14254-13-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20091001082607.GA2181@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Patrick McHardy <kaber@trash.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932370AbZJAIah@vger.kernel.org>
In-Reply-To: <20091001082607.GA2181@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function meth_remove is defined using __exit, so don't use __devexi=
t_p
but __exit_p to wrap it.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Cc: David S. Miller <davem@davemloft.net>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/meth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 92ceb68..2af8173 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -828,7 +828,7 @@ static int __exit meth_remove(struct platform_devic=
e *pdev)
=20
 static struct platform_driver meth_driver =3D {
 	.probe	=3D meth_probe,
-	.remove	=3D __devexit_p(meth_remove),
+	.remove	=3D __exit_p(meth_remove),
 	.driver =3D {
 		.name	=3D "meth",
 		.owner	=3D THIS_MODULE,
--=20
1.6.4.3
