From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Subject: [PATCH 1/3] ath10k: remove multiple defines of DIAG_TRANSFER_LIMIT
Date: Mon, 23 Jan 2017 15:04:34 +0000
Message-ID: <1485183876-27080-1-git-send-email-srinivas.kandagatla@linaro.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DIAG_TRANSFER_LIMIT is redefined with same value and comments
just below this entry, remove this duplicate entry.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
---
 drivers/net/wireless/ath/ath10k/pci.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/pci.h b/drivers/net/wireless/ath/ath10k/pci.h
index 9854ad5..c76789d 100644
--- a/drivers/net/wireless/ath/ath10k/pci.h
+++ b/drivers/net/wireless/ath/ath10k/pci.h
@@ -25,11 +25,6 @@
 #include "ahb.h"
 
 /*
- * maximum number of bytes that can be handled atomically by DiagRead/DiagWrite
- */
-#define DIAG_TRANSFER_LIMIT 2048
-
-/*
  * maximum number of bytes that can be
  * handled atomically by DiagRead/DiagWrite
  */
-- 
2.10.1
