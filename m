From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v5 1/5] soc: qcom: smem_state: Fix include for ERR_PTR()
Date: Mon, 14 Nov 2016 22:06:50 -0800
Message-ID: <1479190014-11297-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Andy Gross <andy.gross@linaro.org>, wcn36xx@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The correct include file for getting errno constants and ERR_PTR() is
linux/err.h, rather than linux/errno.h, so fix the include.

Fixes: e8b123e60084 ("soc: qcom: smem_state: Add stubs for disabled smem_state")
Acked-by: Andy Gross <andy.gross@linaro.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Kalle, please merge this patch through your tree.

Changes since v4:
- New patch

 include/linux/soc/qcom/smem_state.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/soc/qcom/smem_state.h b/include/linux/soc/qcom/smem_state.h
index 7b88697929e9..b8478ee7a71f 100644
--- a/include/linux/soc/qcom/smem_state.h
+++ b/include/linux/soc/qcom/smem_state.h
@@ -1,7 +1,7 @@
 #ifndef __QCOM_SMEM_STATE__
 #define __QCOM_SMEM_STATE__
 
-#include <linux/errno.h>
+#include <linux/err.h>
 
 struct device_node;
 struct qcom_smem_state;
-- 
2.5.0
