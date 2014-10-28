From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCHv3 8/9] net: fec: remove unused return value from swap_buffer()
Date: Tue, 28 Oct 2014 14:23:03 +0100
Message-ID: <1414502584-10583-9-git-send-email-LW@KARO-electronics.de>
References: <1414494104-27943-1-git-send-email-LW@KARO-electronics.de>
 <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	<linux-arm-kernel@lists.infradead.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414502584-10583-1-git-send-email-LW@KARO-electronics.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index ddfc57d..e52864c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -287,7 +287,7 @@ static int fec_enet_get_free_txdesc_num(struct fec_=
enet_private *fep,
 	return entries > 0 ? entries : entries + txq->tx_ring_size;
 }
=20
-static void *swap_buffer(void *bufaddr, int len)
+static void swap_buffer(void *bufaddr, int len)
 {
 	int i;
 	unsigned int *buf =3D bufaddr;
@@ -295,7 +295,6 @@ static void *swap_buffer(void *bufaddr, int len)
 	for (i =3D 0; i < len; i +=3D 4, buf++)
 		swab32s(buf);
=20
-	return bufaddr;
 }
=20
 static void fec_dump(struct net_device *ndev)
--=20
1.7.10.4
