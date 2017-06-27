From: thor.thayer@linux.intel.com
Subject: [PATCH 2/2] ethtool: stmmac: Add DMA HW Feature Register
Date: Tue, 27 Jun 2017 16:51:15 -0500
Message-ID: <1498600275-22334-3-git-send-email-thor.thayer@linux.intel.com>
References: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
Cc: netdev@vger.kernel.org, Thor Thayer <thor.thayer@linux.intel.com>
To: linville@tuxdriver.com, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:57219 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753877AbdF0VsU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 17:48:20 -0400
In-Reply-To: <1498600275-22334-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thor Thayer <thor.thayer@linux.intel.com>

This patch adds the DMA HW Feature Register which is at the end
of the DMA registers and is documented in Version 3.70a.

Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>
---
 stmmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/stmmac.c b/stmmac.c
index e1bb291..7d7bebd 100644
--- a/stmmac.c
+++ b/stmmac.c
@@ -64,7 +64,7 @@ int st_gmac_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 	fprintf(stdout, "\n");
 	fprintf(stdout, "DMA Registers\n");
 	stmmac_reg = (unsigned int *)regs->data + DMA_REG_OFFSET;
-	for (i = 0; i < 22; i++)
+	for (i = 0; i < 23; i++)
 		fprintf(stdout, "Reg%d  0x%08X\n", i, *stmmac_reg++);
 
 	return 0;
-- 
2.7.4
