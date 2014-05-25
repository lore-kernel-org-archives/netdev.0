From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] mwifiex: use time_after()
Date: Sun, 25 May 2014 19:59:36 +0200
Message-ID: <1401040776-13711-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: bzhao@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are
modified to use time_after() instead of plain, error-prone math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 drivers/net/wireless/mwifiex/main.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless=
/mwifiex/main.h
index d53e1e8..3191066 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -1101,7 +1101,7 @@ mwifiex_11h_get_csa_closed_channel(struct mwifiex=
_private *priv)
 		return 0;
=20
 	/* Clear csa channel, if DFS channel move time has passed */
-	if (jiffies > priv->csa_expire_time) {
+	if (time_after(jiffies, priv->csa_expire_time)) {
 		priv->csa_chan =3D 0;
 		priv->csa_expire_time =3D 0;
 	}
--=20
1.7.10.4
