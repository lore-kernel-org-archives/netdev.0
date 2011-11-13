From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH v3 net-next 08/12] bnx2x: remove unused #define
Date: Sun, 13 Nov 2011 16:34:28 +0200
Message-ID: <1321194872-8276-9-git-send-email-dmitry@broadcom.com>
References: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1435 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754091Ab1KMOew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Nov 2011 09:34:52 -0500
In-Reply-To: <1321194872-8276-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index b78c384..23e91f4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1984,13 +1984,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define HW_PRTY_ASSERT_SET_4 (AEU_INPUTS_ATTN_BITS_PGLUE_PARITY_ERROR | \
 			      AEU_INPUTS_ATTN_BITS_ATC_PARITY_ERROR)
 
-#define RSS_FLAGS(bp) \
-		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
-		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_TCP_CAPABILITY | \
-		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_CAPABILITY | \
-		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
-		 (bp->multi_mode << \
-		  TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT))
 #define MULTI_MASK			0x7f
 
 
-- 
1.7.7.2
