From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH net-next v3 1/3] net: ethernet: bgmac: use #defines for MAX size
Date: Tue, 28 Feb 2017 13:50:59 -0500
Message-ID: <1488307861-12118-2-git-send-email-jon.mason@broadcom.com>
References: <1488307861-12118-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488307861-12118-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The maximum frame size is really just the standard ethernet frame size
and FCS.  So use those existing defines to make the code a little more
beautiful.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 6d1c6ff..a75ed35 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -402,7 +402,7 @@
 
 #define BGMAC_WEIGHT	64
 
-#define ETHER_MAX_LEN   1518
+#define ETHER_MAX_LEN	(ETH_FRAME_LEN + ETH_FCS_LEN)
 
 /* Feature Flags */
 #define BGMAC_FEAT_TX_MASK_SETUP	BIT(0)
-- 
2.7.4
