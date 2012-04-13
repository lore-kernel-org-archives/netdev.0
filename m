From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH linux-next 1/1] ath6k: Normalize use of FW_DIR
Date: Fri, 13 Apr 2012 11:17:27 -0600
Message-ID: <1334337448-26270-2-git-send-email-tim.gardner@canonical.com>
References: <1334337448-26270-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: kvalo@qca.qualcomm.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334337448-26270-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/ath/ath6kl/core.h |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index 9d67964..ba81dc8 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -126,9 +126,9 @@ struct ath6kl_fw_ie {
 #define AR6003_HW_2_0_FIRMWARE_FILE		"athwlan.bin.z77"
 #define AR6003_HW_2_0_TCMD_FIRMWARE_FILE	"athtcmd_ram.bin"
 #define AR6003_HW_2_0_PATCH_FILE		"data.patch.bin"
-#define AR6003_HW_2_0_BOARD_DATA_FILE "ath6k/AR6003/hw2.0/bdata.bin"
+#define AR6003_HW_2_0_BOARD_DATA_FILE AR6003_HW_2_0_FW_DIR "/bdata.bin"
 #define AR6003_HW_2_0_DEFAULT_BOARD_DATA_FILE \
-			"ath6k/AR6003/hw2.0/bdata.SD31.bin"
+			AR6003_HW_2_0_FW_DIR "/bdata.SD31.bin"
 
 /* AR6003 3.0 definitions */
 #define AR6003_HW_2_1_1_VERSION                 0x30000582
@@ -139,25 +139,25 @@ struct ath6kl_fw_ie {
 #define AR6003_HW_2_1_1_UTF_FIRMWARE_FILE	"utf.bin"
 #define AR6003_HW_2_1_1_TESTSCRIPT_FILE	"nullTestFlow.bin"
 #define AR6003_HW_2_1_1_PATCH_FILE		"data.patch.bin"
-#define AR6003_HW_2_1_1_BOARD_DATA_FILE "ath6k/AR6003/hw2.1.1/bdata.bin"
+#define AR6003_HW_2_1_1_BOARD_DATA_FILE AR6003_HW_2_1_1_FW_DIR "/bdata.bin"
 #define AR6003_HW_2_1_1_DEFAULT_BOARD_DATA_FILE	\
-			"ath6k/AR6003/hw2.1.1/bdata.SD31.bin"
+			AR6003_HW_2_1_1_FW_DIR "/bdata.SD31.bin"
 
 /* AR6004 1.0 definitions */
 #define AR6004_HW_1_0_VERSION                 0x30000623
 #define AR6004_HW_1_0_FW_DIR			"ath6k/AR6004/hw1.0"
 #define AR6004_HW_1_0_FIRMWARE_FILE		"fw.ram.bin"
-#define AR6004_HW_1_0_BOARD_DATA_FILE         "ath6k/AR6004/hw1.0/bdata.bin"
+#define AR6004_HW_1_0_BOARD_DATA_FILE         AR6004_HW_1_0_FW_DIR "/bdata.bin"
 #define AR6004_HW_1_0_DEFAULT_BOARD_DATA_FILE \
-	"ath6k/AR6004/hw1.0/bdata.DB132.bin"
+	AR6004_HW_1_0_FW_DIR "/bdata.DB132.bin"
 
 /* AR6004 1.1 definitions */
 #define AR6004_HW_1_1_VERSION                 0x30000001
 #define AR6004_HW_1_1_FW_DIR			"ath6k/AR6004/hw1.1"
 #define AR6004_HW_1_1_FIRMWARE_FILE		"fw.ram.bin"
-#define AR6004_HW_1_1_BOARD_DATA_FILE         "ath6k/AR6004/hw1.1/bdata.bin"
+#define AR6004_HW_1_1_BOARD_DATA_FILE         AR6004_HW_1_1_FW_DIR "/bdata.bin"
 #define AR6004_HW_1_1_DEFAULT_BOARD_DATA_FILE \
-	"ath6k/AR6004/hw1.1/bdata.DB132.bin"
+	AR6004_HW_1_1_FW_DIR "/bdata.DB132.bin"
 
 /* Per STA data, used in AP mode */
 #define STA_PS_AWAKE		BIT(0)
-- 
1.7.9.5
