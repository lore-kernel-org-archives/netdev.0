From: thor.thayer@linux.intel.com
Subject: [PATCHv3 2/2] ethtool: stmmac: Add DMA HW Feature Register
Date: Fri,  7 Jul 2017 09:08:49 -0500
Message-ID: <1499436529-4852-2-git-send-email-thor.thayer@linux.intel.com>
References: <1499436529-4852-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, thor.thayer@linux.intel.com
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:60250 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751011AbdGGOFr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Jul 2017 10:05:47 -0400
In-Reply-To: <1499436529-4852-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

This patch adds the DMA HW Feature Register which is at the end
of the DMA registers and is documented in Version 3.70a.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
v2  Modify for MACRO changes and add Acked-by
v3  No change
---
 stmmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/stmmac.c b/stmmac.c
index 23ed31a..79ef151 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -16,7 +16,7 @@
 
 #define MAC100_DMA_REG_NUM	9
 #define GMAC_REG_NUM		55
-#define GMAC_DMA_REG_NUM	22
+#define GMAC_DMA_REG_NUM	23
 
 int st_mac100_dump_regs(struct ethtool_drvinfo *info,
 			struct ethtool_regs *regs)
-- 
2.7.4
