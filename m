From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: usb: fix spelling mistake: "aggreataon"-> "aggregation"
Date: Mon, 24 Jul 2017 23:26:23 +0100
Message-ID: <20170724222623.16652-1-colin.king@canonical.com>
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

Trivial fix to spelling mistake in aggr_ctrl module parameter
message text.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index f2600b827e81..ebe2c9319948 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -46,7 +46,7 @@ MODULE_PARM_DESC(mfg_mode, "manufacturing mode enable:1, disable:0");
 
 bool aggr_ctrl;
 module_param(aggr_ctrl, bool, 0000);
-MODULE_PARM_DESC(aggr_ctrl, "usb tx aggreataon enable:1, disable:0");
+MODULE_PARM_DESC(aggr_ctrl, "usb tx aggregation enable:1, disable:0");
 
 /*
  * This function registers the device and performs all the necessary
-- 
2.11.0
