From: Denis Efremov <yefremov.denis@gmail.com>
Subject: [PATCH 08/21] iwlegacy: remove inline marking of EXPORT_SYMBOL functions
Date: Thu,  9 May 2013 13:19:39 +0400
Message-ID: <1368091192-10245-3-git-send-email-yefremov.denis@gmail.com>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Cc: Denis Efremov <yefremov.denis@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org,
	ldv-project@linuxtesting.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL and inline directives are contradictory to each other.
The patch fixes this inconsistency.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
---
 drivers/net/wireless/iwlegacy/common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 592d0aa..e9a3cbc 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -1423,7 +1423,7 @@ il_setup_rx_scan_handlers(struct il_priv *il)
 }
 EXPORT_SYMBOL(il_setup_rx_scan_handlers);
 
-inline u16
+u16
 il_get_active_dwell_time(struct il_priv *il, enum ieee80211_band band,
 			 u8 n_probes)
 {
-- 
1.8.1.4
