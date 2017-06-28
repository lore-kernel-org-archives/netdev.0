From: thor.thayer@linux.intel.com
Subject: [PATCHv2 3/3] ethtool: stmmac: Add DMA HW Feature Register
Date: Wed, 28 Jun 2017 10:13:42 -0500
Message-ID: <1498662822-12173-4-git-send-email-thor.thayer@linux.intel.com>
References: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15047 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751669AbdF1PLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 11:11:16 -0400
In-Reply-To: <1498662822-12173-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

This patch adds the DMA HW Feature Register which is at the end
of the DMA registers and is documented in Version 3.70a.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
v2  Modify for MACRO changes and add Acked-by
---
 stmmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/stmmac.c b/stmmac.c
index ab83779..e5d8c7b 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -16,7 +16,7 @@
 
 #define MAC100_DMA_REG_NUM	9
 #define GMAC_REG_NUM		55
-#define GMAC_DMA_REG_NUM	22
+#define GMAC_DMA_REG_NUM	23
 
 /* The DMA Registers start at offset 0x1000 in the DW IP */
 #define DMA_REG_OFFSET	(0x1000 / 4)
-- 
2.7.4
