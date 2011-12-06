From: =?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH][NET] several cleanups and bugfixes for fec.c: set con_id in clk_get() call to NULL
Date: Tue,  6 Dec 2011 11:27:10 +0100
Message-ID: <6c28f25c5c6d2f88d0985ce361c5e16f19db27d0.1323163127.git.LW@KARO-electronics.de>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323163127.git.LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, Shawn Guo <shawn.guo@linaro.org>,
	linux-arm-kernel@lists.infradead.org,
	=?utf-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bd4415514fa0b40ece04d56b3ac4f549e79d87d7.1323163127.git.LW@KARO-electronics.de>
In-Reply-To: <cover.1323163127.git.LW@KARO-electronics.de>
References: <cover.1323163127.git.LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The con_id is actually not needed for clk_get().

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/etherne=
t/freescale/fec.c
index f224e58..65ee506 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1585,7 +1585,7 @@ fec_probe(struct platform_device *pdev)
 		}
 	}
=20
-	fep->clk =3D clk_get(&pdev->dev, "fec_clk");
+	fep->clk =3D clk_get(&pdev->dev, NULL);
 	if (IS_ERR(fep->clk)) {
 		ret =3D PTR_ERR(fep->clk);
 		goto failed_clk;
--=20
1.5.6.5
