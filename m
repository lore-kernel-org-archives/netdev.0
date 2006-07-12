From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/7] sky2: fix truncated collision threshold mask
Date: Wed, 12 Jul 2006 15:23:42 -0700
Message-ID: <20060712222645.703394439@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23945 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932066AbWGLWcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:32:17 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-thr-msk.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to correct broken collision threshold mask in sky2 driver.  Should be
three bits wide, but the mask only allows for 1 bit to be set.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

 sky2.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 8a0bc55..2db8d19 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1480,7 +1480,7 @@ enum {
 	GM_TXCR_FORCE_JAM	= 1<<15, /* Bit 15:	Force Jam / Flow-Control */
 	GM_TXCR_CRC_DIS		= 1<<14, /* Bit 14:	Disable insertion of CRC */
 	GM_TXCR_PAD_DIS		= 1<<13, /* Bit 13:	Disable padding of packets */
-	GM_TXCR_COL_THR_MSK	= 1<<10, /* Bit 12..10:	Collision Threshold */
+	GM_TXCR_COL_THR_MSK	= 7<<10, /* Bit 12..10:	Collision Threshold */
 };
 
 #define TX_COL_THR(x)		(((x)<<10) & GM_TXCR_COL_THR_MSK)
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/

--

