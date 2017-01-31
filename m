From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 09/17] net: stmmac: replace ENOSYS by EINVAL
Date: Tue, 31 Jan 2017 10:11:44 +0100
Message-ID: <20170131091152.13842-10-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36755 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdAaJXe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:23:34 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As said by checkpatch ENOSYS means 'invalid syscall nr' and nothing
else.
This patch replace ENOSYS by the more appropriate value EINVAL.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index eff6282..485b1cd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -353,7 +353,7 @@ void stmmac_remove_config_dt(struct platform_device *pdev,
 struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
-	return ERR_PTR(-ENOSYS);
+	return ERR_PTR(-EINVAL);
 }
 
 void stmmac_remove_config_dt(struct platform_device *pdev,
-- 
2.10.2
