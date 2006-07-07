From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sky2: fix trucated collision threshold mask
Date: Fri, 7 Jul 2006 13:40:21 -0400
Message-ID: <20060707174021.GA8636@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:19219 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932233AbWGGRkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 13:40:49 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch to correct broken collision threshold mask in sky2 driver.  Should be
three bits wide, but the mask only allows for 1 bit to be set.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

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
