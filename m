From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/4] stmmac: fix LPI TW timer value to 20.5us.
Date: Thu, 28 Aug 2014 08:11:42 +0200
Message-ID: <1409206304-23239-3-git-send-email-peppe.cavallaro@st.com>
References: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, nandini sharma <nandini.sharma@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:34991 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934150AbaH1GL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:11:56 -0400
In-Reply-To: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nandini sharma <nandini.sharma@st.com>

The value for LPI TW timer has to be updated to 0x1E that is the hardcoded value
of 20.5us and it will apply to all EEE enabled Remote PHYs.
Disadvantage is for PHY's that support lesser wakeup time but we can accept it
waiting to implement LLDP to negotiate the Wakeup time of Remote PHY.

Signed-off-by: nandini sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index a464e8c..9f3e8b4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -287,7 +287,7 @@ struct dma_features {
 
 /* Default LPI timers */
 #define STMMAC_DEFAULT_LIT_LS	0x3E8
-#define STMMAC_DEFAULT_TWT_LS	0x0
+#define STMMAC_DEFAULT_TWT_LS	0x1E
 
 #define STMMAC_CHAIN_MODE	0x1
 #define STMMAC_RING_MODE	0x2
-- 
1.7.4.4
