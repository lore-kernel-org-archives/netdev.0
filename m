From: Colin King <colin.king@canonical.com>
Subject: [PATCH] drivers: net: stmmac: fix spelling mistake "mulitcast" -> "multicast"
Date: Fri, 26 Aug 2016 19:35:25 +0100
Message-ID: <20160826183525.2366-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48659 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbcHZShw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in dev_warn message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
index cbefe9e..6f6bbc5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -145,7 +145,7 @@ static void dwmac1000_set_mchash(void __iomem *ioaddr, u32 *mcfilterbits,
 		numhashregs = 8;
 		break;
 	default:
-		pr_debug("STMMAC: err in setting mulitcast filter\n");
+		pr_debug("STMMAC: err in setting multicast filter\n");
 		return;
 		break;
 	}
-- 
2.9.3
