From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 5/5] bnx2x: Use correct FW constant for header
 padding
Date: Mon, 11 Oct 2010 00:30:38 +0200
Message-ID: <1286749838.4669.32.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3060 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab0JJWcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Oct 2010 18:32:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


the value of the constant is the same, but it's clearer to use original
constant provided by HSI

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/bnx2x/bnx2x_cmn.h |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 9a3208e..29ed500 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -830,7 +830,7 @@ void bnx2x_init_rx_rings(struct bnx2x *bp)
 	int i, j;
 
 	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN +
-		BNX2X_FW_IP_HDR_ALIGN_PAD;
+		IP_HEADER_ALIGNMENT_PADDING;
 
 	DP(NETIF_MSG_IFUP,
 	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 7f52cec..5bfe0ab 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -1032,6 +1032,4 @@ static inline void storm_memset_cmng(struct bnx2x *bp,
 void bnx2x_acquire_phy_lock(struct bnx2x *bp);
 void bnx2x_release_phy_lock(struct bnx2x *bp);
 
-#define BNX2X_FW_IP_HDR_ALIGN_PAD	2 /* FW places hdr with this padding */
-
 #endif /* BNX2X_CMN_H */
-- 
1.7.1




