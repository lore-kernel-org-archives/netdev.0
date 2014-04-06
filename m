From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] rsi: Add missing initialization of ii
Date: Sun,  6 Apr 2014 15:30:39 +0200
Message-ID: <1396791040-26816-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/wireless/rsi/rsi_91x_core.c: In function =E2=80=98rsi_core_=
determine_hal_queue=E2=80=99:
drivers/net/wireless/rsi/rsi_91x_core.c:91: warning: =E2=80=98ii=E2=80=99=
 may be used uninitialized in this function

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Is zero the correct initialization value?

 drivers/net/wireless/rsi/rsi_91x_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_core.c b/drivers/net/wire=
less/rsi/rsi_91x_core.c
index e89535e86caf..20a62f36e89b 100644
--- a/drivers/net/wireless/rsi/rsi_91x_core.c
+++ b/drivers/net/wireless/rsi/rsi_91x_core.c
@@ -88,7 +88,7 @@ static u8 rsi_core_determine_hal_queue(struct rsi_com=
mon *common)
 	bool recontend_queue =3D false;
 	u32 q_len =3D 0;
 	u8 q_num =3D INVALID_QUEUE;
-	u8 ii, min =3D 0;
+	u8 ii =3D 0, min =3D 0;
=20
 	if (skb_queue_len(&common->tx_queue[MGMT_SOFT_Q])) {
 		if (!common->mgmt_q_block)
--=20
1.7.9.5
