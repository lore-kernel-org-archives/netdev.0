From: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: [PATCH 8/8] net: fec: remove unused return value from swap_buffer()
Date: Mon, 17 Nov 2014 10:51:24 +0100
Message-ID: <1416217884-20911-9-git-send-email-LW@KARO-electronics.de>
References: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Lothar=20Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	netdev@vger.kernel.org, Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <fugang.duan@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:53278 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaKQJvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 04:51:43 -0500
In-Reply-To: <1416217884-20911-1-git-send-email-LW@KARO-electronics.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value of swap_buffer() is not used by any caller, thus
remove it.

Signed-off-by: Lothar Wa=C3=9Fmann <LW@KARO-electronics.de>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index dbccdf3..1b6d26b 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -287,15 +287,13 @@ static int fec_enet_get_free_txdesc_num(struct fe=
c_enet_private *fep,
 	return entries > 0 ? entries : entries + txq->tx_ring_size;
 }
=20
-static void *swap_buffer(void *bufaddr, int len)
+static void swap_buffer(void *bufaddr, int len)
 {
 	int i;
 	unsigned int *buf =3D bufaddr;
=20
 	for (i =3D 0; i < len; i +=3D 4, buf++)
 		swab32s(buf);
-
-	return bufaddr;
 }
=20
 static void swap_buffer2(void *dst_buf, void *src_buf, int len)
--=20
1.7.10.4
