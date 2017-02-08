From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 09/16] net: stmmac: replace ENOSYS by EINVAL
Date: Wed,  8 Feb 2017 09:31:14 +0100
Message-ID: <20170208083121.27949-10-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As said by checkpatch ENOSYS means 'invalid syscall nr' and nothing
else.
This patch replace ENOSYS by the more appropriate value EINVAL.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 320f46e..433a842 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -411,7 +411,7 @@ void stmmac_remove_config_dt(struct platform_device *pdev,
 struct plat_stmmacenet_data *
 stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 {
-	return ERR_PTR(-ENOSYS);
+	return ERR_PTR(-EINVAL);
 }
 
 void stmmac_remove_config_dt(struct platform_device *pdev,
-- 
2.10.2
