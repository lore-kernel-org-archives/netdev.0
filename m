From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: fix spelling mistake: "secuirty" -> "security"
Date: Wed, 28 Jun 2017 16:50:54 +0100
Message-ID: <20170628155054.27885-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in mwifiex_dbg message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/cfg80211.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/cfg80211.c b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
index a850ec0054e2..d8ff823c0818 100644
--- a/drivers/net/wireless/marvell/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/marvell/mwifiex/cfg80211.c
@@ -1981,7 +1981,7 @@ static int mwifiex_cfg80211_start_ap(struct wiphy *wiphy,
 
 	if (mwifiex_set_secure_params(priv, bss_cfg, params)) {
 		mwifiex_dbg(priv->adapter, ERROR,
-			    "Failed to parse secuirty parameters!\n");
+			    "Failed to parse security parameters!\n");
 		goto out;
 	}
 
-- 
2.11.0
