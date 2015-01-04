From: Giel van Schijndel <me@mortis.eu>
Subject: [PATCH 2/2] Fix copy-paste bug: assign from src struct not dest
Date: Sun,  4 Jan 2015 19:00:23 +0100
Message-ID: <1420394427-19509-2-git-send-email-me@mortis.eu>
References: <1420394427-19509-1-git-send-email-me@mortis.eu>
Cc: Giel van Schijndel <me@mortis.eu>,
	Kalle Valo <kvalo@codeaurora.org>,
	Eliad Peller <eliad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arik Nemtsov <arik@wizery.com>,
	linux-wireless@vger.kernel.org (open list:TI WILINK WIRELES...),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420394427-19509-1-git-send-email-me@mortis.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

---
 drivers/net/wireless/ti/wlcore/acx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/acx.c b/drivers/net/wireless/ti/wlcore/acx.c
index beb354c..93a2fa8 100644
--- a/drivers/net/wireless/ti/wlcore/acx.c
+++ b/drivers/net/wireless/ti/wlcore/acx.c
@@ -1725,7 +1725,7 @@ int wl12xx_acx_config_hangover(struct wl1271 *wl)
 	acx->decrease_delta             = conf->decrease_delta;
 	acx->quiet_time                 = conf->quiet_time;
 	acx->increase_time              = conf->increase_time;
-	acx->window_size                = acx->window_size;
+	acx->window_size                = conf->window_size;
 
 	ret = wl1271_cmd_configure(wl, ACX_CONFIG_HANGOVER, acx,
 				   sizeof(*acx));
-- 
2.1.4
