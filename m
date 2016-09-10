From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ethernet: dwmac: fix non static symbol warning
Date: Sat, 10 Sep 2016 12:31:30 +0000
Message-ID: <1473510690-25198-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36263 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbcIJMbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 08:31:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id x24so5391023pfa.3
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 05:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c:172:1: warning:
 symbol 'stm32_dwmac_pm_ops' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
index 79d8b92..e5a926b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
@@ -169,7 +169,8 @@ static int stm32_dwmac_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-SIMPLE_DEV_PM_OPS(stm32_dwmac_pm_ops, stm32_dwmac_suspend, stm32_dwmac_resume);
+static SIMPLE_DEV_PM_OPS(stm32_dwmac_pm_ops,
+	stm32_dwmac_suspend, stm32_dwmac_resume);
 
 static const struct of_device_id stm32_dwmac_match[] = {
 	{ .compatible = "st,stm32-dwmac"},
