From: Giel van Schijndel <me@mortis.eu>
Subject: [PATCH RESEND 2/2] wlcore: align member-assigns in a structure-copy block
Date: Wed,  7 Jan 2015 20:38:38 +0100
Message-ID: <1420659525-22975-2-git-send-email-me@mortis.eu>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
 <1420659525-22975-1-git-send-email-me@mortis.eu>
Cc: Giel van Schijndel <me@mortis.eu>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	linux-wireless@vger.kernel.org (open list:TI WILINK WIRELES...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420659525-22975-1-git-send-email-me@mortis.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This highlights the differences (e.g. the bug fixed in the previous
commit).

Signed-off-by: Giel van Schijndel <me@mortis.eu>
---
 drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index f28fa3b..93a2fa8 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -1715,17 +1715,17 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
 		goto out;
 	}
 
-	acx->recover_time = cpu_to_le32(conf->recover_time);
-	acx->hangover_period = conf->hangover_period;
-	acx->dynamic_mode = conf->dynamic_mode;
-	acx->early_termination_mode = conf->early_termination_mode;
-	acx->max_period = conf->max_period;
-	acx->min_period = conf->min_period;
-	acx->increase_delta = conf->increase_delta;
-	acx->decrease_delta = conf->decrease_delta;
-	acx->quiet_time = conf->quiet_time;
-	acx->increase_time = conf->increase_time;
-	acx->window_size = conf->window_size;
+	acx->recover_time               = cpu_to_le32(conf->recover_time);
+	acx->hangover_period            = conf->hangover_period;
+	acx->dynamic_mode               = conf->dynamic_mode;
+	acx->early_termination_mode     = conf->early_termination_mode;
+	acx->max_period                 = conf->max_period;
+	acx->min_period                 = conf->min_period;
+	acx->increase_delta             = conf->increase_delta;
+	acx->decrease_delta             = conf->decrease_delta;
+	acx->quiet_time                 = conf->quiet_time;
+	acx->increase_time              = conf->increase_time;
+	acx->window_size                = conf->window_size;
 
 	ret = wl1271_cmd_configure(wl, ACX_CONFIG_HANGOVER, acx,
 				   sizeof(*acx));
-- 
2.1.4
