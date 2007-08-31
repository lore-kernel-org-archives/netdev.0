From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH] ucc_geth: suppress 'qe_bd_t' undeclared error
Date: Fri, 31 Aug 2007 11:35:51 -0500
Message-ID: <20070831113551.ebc91dbd.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Li Yang <leoli@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:47655 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754219AbXHaQfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 12:35:55 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l7VGZr87021455
	for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 09:35:53 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ucc_geth.c:2151: error: =E2=80=98qe_bd_t=E2=80=99 undeclare=
d (first use in this function)

Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
Leo, this is for 2.6.23.

 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..9a38dfe 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2148,7 +2148,7 @@ static void ucc_geth_memclean(struct ucc_geth_pri=
vate *ugeth)
 		for (j =3D 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
 			if (ugeth->tx_skbuff[i][j]) {
 				dma_unmap_single(NULL,
-						 ((qe_bd_t *)bd)->buf,
+						 ((struct qe_bd *)bd)->buf,
 						 (in_be32((u32 *)bd) &
 						  BD_LENGTH_MASK),
 						 DMA_TO_DEVICE);
--=20
1.5.2.2

