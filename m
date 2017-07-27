From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"
Date: Thu, 27 Jul 2017 23:06:22 +0100
Message-ID: <20170727220622.11957-1-colin.king@canonical.com>
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

Trivial fix to spelling mistake in mwifiex_dbg debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/tdls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index 39cd677d4159..e76af2866a19 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -130,7 +130,7 @@ mwifiex_tdls_append_rates_ie(struct mwifiex_private *priv,
 
 	if (skb_tailroom(skb) < rates_size + 4) {
 		mwifiex_dbg(priv->adapter, ERROR,
-			    "Insuffient space while adding rates\n");
+			    "Insufficient space while adding rates\n");
 		return -ENOMEM;
 	}
 
-- 
2.11.0
