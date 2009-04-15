From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 01/12] fec: remove unused ifdef
Date: Wed, 15 Apr 2009 13:32:14 +0200
Message-ID: <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37922 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758038AbZDOLet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:34:49 -0400
In-Reply-To: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.h |   44 --------------------------------------------
 1 files changed, 0 insertions(+), 44 deletions(-)

diff --git a/drivers/net/fec.h b/drivers/net/fec.h
index 76c64c9..c2f97f3 100644
--- a/drivers/net/fec.h
+++ b/drivers/net/fec.h
@@ -13,8 +13,6 @@
 #define	FEC_H
 /****************************************************************************/
 
-#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
-    defined(CONFIG_M520x) || defined(CONFIG_M532x) || defined(CONFIG_ARCH_MXC)
 /*
  *	Just figures, Motorola would have to change the offsets for
  *	registers in the same peripheral device on different models
@@ -58,48 +56,6 @@ typedef struct fec {
 	unsigned long	fec_r_buff_size;	/* Maximum receive buff size */
 } fec_t;
 
-#else
-
-/*
- *	Define device register set address map.
- */
-typedef struct fec {
-	unsigned long	fec_ecntrl;		/* Ethernet control reg */
-	unsigned long	fec_ievent;		/* Interrupt even reg */
-	unsigned long	fec_imask;		/* Interrupt mask reg */
-	unsigned long	fec_ivec;		/* Interrupt vec status reg */
-	unsigned long	fec_r_des_active;	/* Receive descriptor reg */
-	unsigned long	fec_x_des_active;	/* Transmit descriptor reg */
-	unsigned long	fec_reserved1[10];
-	unsigned long	fec_mii_data;		/* MII manage frame reg */
-	unsigned long	fec_mii_speed;		/* MII speed control reg */
-	unsigned long	fec_reserved2[17];
-	unsigned long	fec_r_bound;		/* FIFO receive bound reg */
-	unsigned long	fec_r_fstart;		/* FIFO receive start reg */
-	unsigned long	fec_reserved3[4];
-	unsigned long	fec_x_wmrk;		/* FIFO transmit water mark */
-	unsigned long	fec_reserved4;
-	unsigned long	fec_x_fstart;		/* FIFO transmit start reg */
-	unsigned long	fec_reserved5[21];
-	unsigned long	fec_r_cntrl;		/* Receive control reg */
-	unsigned long	fec_max_frm_len;	/* Maximum frame length reg */
-	unsigned long	fec_reserved6[14];
-	unsigned long	fec_x_cntrl;		/* Transmit Control reg */
-	unsigned long	fec_reserved7[158];
-	unsigned long	fec_addr_low;		/* Low 32bits MAC address */
-	unsigned long	fec_addr_high;		/* High 16bits MAC address */
-	unsigned long	fec_grp_hash_table_high;/* High 32bits hash table */
-	unsigned long	fec_grp_hash_table_low;	/* Low 32bits hash table */
-	unsigned long	fec_r_des_start;	/* Receive descriptor ring */
-	unsigned long	fec_x_des_start;	/* Transmit descriptor ring */
-	unsigned long	fec_r_buff_size;	/* Maximum receive buff size */
-	unsigned long	reserved8[9];
-	unsigned long	fec_fifo_ram[112];	/* FIFO RAM buffer */
-} fec_t;
-
-#endif /* CONFIG_M5272 */
-
-
 /*
  *	Define the buffer descriptor structure.
  */
-- 
1.6.2.1

