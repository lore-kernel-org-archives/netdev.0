From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] isdn: hisax: clean up some indenting
Date: Sat, 3 May 2014 23:20:12 +0300
Message-ID: <20140503202012.GC32753@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <jkosina@suse.cz>,
	Randy Dunlap <rdunlap@infradead.org>,
	Masanari Iida <standby24x7@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18229 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaECUVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 16:21:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The indenting is off the ifdefed code is intended to be a part of the
body of the if statement.  I have cleaned it up a bit.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 414dbf6..aaade90 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -738,12 +738,13 @@ rx_d_frame(struct hfc4s8s_l1 *l1p, int ech)
 					z1 -= 4;
 				}
 
-				while (z1--)
+				while (z1--) {
 #ifdef HISAX_HFC4S8S_PCIMEM
 					Read_hfc8(l1p->hw, A_FIFO_DATA0);
 #else
-				fRead_hfc8(l1p->hw);
+					fRead_hfc8(l1p->hw);
 #endif
+				}
 
 				Write_hfc8(l1p->hw, A_INC_RES_FIFO, 1);
 				wait_busy(l1p->hw);
@@ -768,12 +769,13 @@ rx_d_frame(struct hfc4s8s_l1 *l1p, int ech)
 			z1 -= 4;
 		}
 
-		while (z1--)
+		while (z1--) {
 #ifdef HISAX_HFC4S8S_PCIMEM
 			*cp++ = Read_hfc8(l1p->hw, A_FIFO_DATA0);
 #else
-		*cp++ = fRead_hfc8(l1p->hw);
+			*cp++ = fRead_hfc8(l1p->hw);
 #endif
+		}
 
 		Write_hfc8(l1p->hw, A_INC_RES_FIFO, 1);	/* increment f counter */
 		wait_busy(l1p->hw);
@@ -875,12 +877,13 @@ rx_b_frame(struct hfc4s8s_btype *bch)
 			z1 -= 4;
 		}
 
-		while (z1--)
+		while (z1--) {
 #ifdef HISAX_HFC4S8S_PCIMEM
 			*(bch->rx_ptr++) = Read_hfc8(l1->hw, A_FIFO_DATA0);
 #else
-		*(bch->rx_ptr++) = fRead_hfc8(l1->hw);
+			*(bch->rx_ptr++) = fRead_hfc8(l1->hw);
 #endif
+		}
 
 		if (hdlc_complete) {
 			/* increment f counter */
@@ -1051,12 +1054,13 @@ tx_b_frame(struct hfc4s8s_btype *bch)
 			cnt -= 4;
 		}
 
-		while (cnt--)
+		while (cnt--) {
 #ifdef HISAX_HFC4S8S_PCIMEM
 			fWrite_hfc8(l1->hw, A_FIFO_DATA0, *cp++);
 #else
-		fWrite_hfc8(l1->hw, *cp++);
+			fWrite_hfc8(l1->hw, *cp++);
 #endif
+		}
 
 		if (bch->tx_cnt >= skb->len) {
 			if (bch->mode == L1_MODE_HDLC) {
