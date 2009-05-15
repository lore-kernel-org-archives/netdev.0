From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] Neterion: *FIFO1_DMA_ERR set twice, should 2nd be *FIFO2_DMA_ERR?
Date: Fri, 15 May 2009 22:19:51 +0200
Message-ID: <4A0DCE67.70106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:41819 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbZEOUTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 16:19:50 -0400
Received: by ewy24 with SMTP id 24so2743486ewy.37
        for <netdev@vger.kernel.org>; Fri, 15 May 2009 13:19:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FIFO1_DMA_ERR is set twice, the second should be FIFO2_DMA_ERR.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Correct? Please review.

diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 7be0ae1..c2eeac4 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -115,7 +115,7 @@ enum vxge_hw_status vxge_hw_vpath_intr_enable(struct __vxge_hw_vpath_handle *vp)
 		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_POISON|
 		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO2_POISON|
 		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_DMA_ERR|
-		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO1_DMA_ERR), 0, 32),
+		VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO2_DMA_ERR), 0, 32),
 		&vp_reg->kdfcctl_errors_mask);
 
 	__vxge_hw_pio_mem_write32_upper(0, &vp_reg->vpath_ppif_int_mask);
