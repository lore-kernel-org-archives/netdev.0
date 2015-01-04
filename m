From: Giel van Schijndel <me@mortis.eu>
Subject: [PATCH 1/2] Align member-assigns in a structure-copy block
Date: Sun,  4 Jan 2015 19:00:22 +0100
Message-ID: <1420394427-19509-1-git-send-email-me@mortis.eu>
Cc: Giel van Schijndel <me@mortis.eu>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	linux-wireless@vger.kernel.org (open list:TI WILINK WIRELES...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from khitomer.mortis.eu ([185.27.175.75]:11418 "EHLO
	khitomer.mortis.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbbADTK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 14:10:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This highlights the differences (errors).
---
 drivers/net/wireless/ti/wlcore/acx.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index b924cea..beb354c 100644
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
-	acx->window_size = acx->window_size;
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
+	acx->window_size                = acx->window_size;
 
 	ret = wl1271_cmd_configure(wl, ACX_CONFIG_HANGOVER, acx,
 				   sizeof(*acx));
-- 
2.1.4
