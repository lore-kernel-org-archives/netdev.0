From: Nikitas Angelinas <nikitasangelinas@gmail.com>
Subject: [PATCH 6/8] drivers/net/wireless/ath/ath9k: use ARRAY_SIZE macro in ani.c
Date: Wed,  8 Sep 2010 22:25:42 +0100
Message-ID: <1283981142-5062-1-git-send-email-nikitasangelinas@gmail.com>
References: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikitas Angelinas <nikitasangelinas@gmail.com>
To: lrodriguez@atheros.com, jmalinen@atheros.com, vasanth@atheros.com,
	senthilkumar@atheros.com, linville@tuxdriver.com,
	Sujith.Manoharan@atheros.com, nbd@openwrt.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace (sizeof(ofdm_level_table)/sizeof(ofdm_level_table[0]) with
ARRAY_SIZE(ofdm_level_table), and (sizeof(cck_level_table)/
sizeof(cck_level_table[0]) with ARRAY_SIZE(cck_level_table) in
drivers/net/wireless/ath/ath9k/ani.c

Signed-off-by: Nikitas Angelinas <nikitasangelinas@gmail.com>
---
 drivers/net/wireless/ath/ath9k/ani.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ani.c b/drivers/net/wireless/ath/ath9k/ani.c
index cc648b6..0496f96 100644
--- a/drivers/net/wireless/ath/ath9k/ani.c
+++ b/drivers/net/wireless/ath/ath9k/ani.c
@@ -14,6 +14,7 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/kernel.h>
 #include "hw.h"
 #include "hw-ops.h"
 
@@ -48,7 +49,7 @@ static const struct ani_ofdm_level_entry ofdm_level_table[] = {
 	{  7,  8,  0  }  /* lvl 9 */
 };
 #define ATH9K_ANI_OFDM_NUM_LEVEL \
-	(sizeof(ofdm_level_table)/sizeof(ofdm_level_table[0]))
+	ARRAY_SIZE(ofdm_level_table)
 #define ATH9K_ANI_OFDM_MAX_LEVEL \
 	(ATH9K_ANI_OFDM_NUM_LEVEL-1)
 #define ATH9K_ANI_OFDM_DEF_LEVEL \
@@ -94,7 +95,7 @@ static const struct ani_cck_level_entry cck_level_table[] = {
 };
 
 #define ATH9K_ANI_CCK_NUM_LEVEL \
-	(sizeof(cck_level_table)/sizeof(cck_level_table[0]))
+	ARRAY_SIZE(cck_level_table)
 #define ATH9K_ANI_CCK_MAX_LEVEL \
 	(ATH9K_ANI_CCK_NUM_LEVEL-1)
 #define ATH9K_ANI_CCK_MAX_LEVEL_LOW_RSSI \
-- 
1.7.2.3
