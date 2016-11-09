From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/2] wcn36xx: Correct Kconfig dependency
Date: Wed,  9 Nov 2016 10:02:50 -0800
Message-ID: <1478714571-4841-1-git-send-email-bjorn.andersson@linaro.org>
References: <201611092150.OxpAuHow%fengguang.wu@intel.com>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Gross <andy.gross@linaro.org>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611092150.OxpAuHow%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the case SMD or WCNSS_CTRL are compiled as modules, wcn36xx must be
compiled as module as well, so we need to mention this dependency.
But we still want allow the driver to be compiled in case either of
those are =n, for compile testing reasons.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/Kconfig | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/Kconfig b/drivers/net/wireless/ath/wcn36xx/Kconfig
index 591ebaea8265..4b83e87f0b94 100644
--- a/drivers/net/wireless/ath/wcn36xx/Kconfig
+++ b/drivers/net/wireless/ath/wcn36xx/Kconfig
@@ -1,6 +1,8 @@
 config WCN36XX
 	tristate "Qualcomm Atheros WCN3660/3680 support"
 	depends on MAC80211 && HAS_DMA
+	depends on QCOM_WCNSS_CTRL || QCOM_WCNSS_CTRL=n
+	depends on QCOM_SMD || QCOM_SMD=n
 	---help---
 	  This module adds support for wireless adapters based on
 	  Qualcomm Atheros WCN3660 and WCN3680 mobile chipsets.
-- 
2.5.0
