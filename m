From: Emil Medve <Emilian.Medve@freescale.com>
Subject: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Thu, 18 Oct 2007 17:15:13 -0500
Message-ID: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
Cc: Emil Medve <Emilian.Medve@freescale.com>
To: jgarzik@pobox.com, leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45849 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810AbXJSAHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 20:07:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ucc_geth.c: In function 'ucc_geth_startup':
drivers/net/ucc_geth.c:2614: warning: assignment makes integer from pointer without a cast
drivers/net/ucc_geth.c:2651: warning: assignment makes integer from pointer without a cast

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---

This patch is against Jeff's tree: d85714d81cc0408daddb68c10f7fd69eafe7c213 

netdev-2.6> scripts/checkpatch.pl 0001-POWERPC-ucc_geth-Eliminate-compile-warnings.patch 
Your patch has no obvious style problems and is ready for submission.

 drivers/net/ucc_geth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index bec413b..d427da8 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2611,7 +2611,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_TX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_TX_BD_RING_ALIGNMENT;
 			ugeth->tx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32)kmalloc(length + align, GFP_KERNEL);
 
 			if (ugeth->tx_bd_ring_offset[j] != 0)
 				ugeth->p_tx_bd_ring[j] =
@@ -2648,7 +2648,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (UCC_GETH_RX_BD_RING_ALIGNMENT > 4)
 				align = UCC_GETH_RX_BD_RING_ALIGNMENT;
 			ugeth->rx_bd_ring_offset[j] =
-				kmalloc((u32) (length + align), GFP_KERNEL);
+				(u32)kmalloc(length + align, GFP_KERNEL);
 			if (ugeth->rx_bd_ring_offset[j] != 0)
 				ugeth->p_rx_bd_ring[j] =
 					(void*)((ugeth->rx_bd_ring_offset[j] +
-- 
1.5.3.GIT

