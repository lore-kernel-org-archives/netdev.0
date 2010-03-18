From: Joe Perches <joe@perches.com>
Subject: [PATCH v2 4/7] drivers/net/wireless: Use STD_IW_HANDLER macro
Date: Wed, 17 Mar 2010 23:21:37 -0700
Message-ID: <b628c684e970196a7c4c0966ddd599a4c2ce293e.1268892664.git.joe@perches.com>
References: <cover.1268892663.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Corey Thomas <coreythomas@charter.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268892663.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert direct uses of [ (foo - SIOCIWFIRST) , fn)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ray_cs.c    |   40 ++++++++++++++--------------
 drivers/net/wireless/wl3501_cs.c |   52 +++++++++++++++++++-------------------
 2 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 84c530a..d25ed5a 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1531,28 +1531,28 @@ static iw_stats *ray_get_wireless_stats(struct net_device *dev)
  */
 
 static const iw_handler ray_handler[] = {
-	[SIOCSIWCOMMIT - SIOCIWFIRST] = (iw_handler) ray_commit,
-	[SIOCGIWNAME - SIOCIWFIRST] = (iw_handler) ray_get_name,
-	[SIOCSIWFREQ - SIOCIWFIRST] = (iw_handler) ray_set_freq,
-	[SIOCGIWFREQ - SIOCIWFIRST] = (iw_handler) ray_get_freq,
-	[SIOCSIWMODE - SIOCIWFIRST] = (iw_handler) ray_set_mode,
-	[SIOCGIWMODE - SIOCIWFIRST] = (iw_handler) ray_get_mode,
-	[SIOCGIWRANGE - SIOCIWFIRST] = (iw_handler) ray_get_range,
+	STD_IW_HANDLER(SIOCSIWCOMMIT, ray_commit),
+	STD_IW_HANDLER(SIOCGIWNAME, ray_get_name),
+	STD_IW_HANDLER(SIOCSIWFREQ, ray_set_freq),
+	STD_IW_HANDLER(SIOCGIWFREQ, ray_get_freq),
+	STD_IW_HANDLER(SIOCSIWMODE, ray_set_mode),
+	STD_IW_HANDLER(SIOCGIWMODE, ray_get_mode),
+	STD_IW_HANDLER(SIOCGIWRANGE, ray_get_range),
 #ifdef WIRELESS_SPY
-	[SIOCSIWSPY - SIOCIWFIRST] = (iw_handler) iw_handler_set_spy,
-	[SIOCGIWSPY - SIOCIWFIRST] = (iw_handler) iw_handler_get_spy,
-	[SIOCSIWTHRSPY - SIOCIWFIRST] = (iw_handler) iw_handler_set_thrspy,
-	[SIOCGIWTHRSPY - SIOCIWFIRST] = (iw_handler) iw_handler_get_thrspy,
+	STD_IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
+	STD_IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
+	STD_IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
+	STD_IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
 #endif /* WIRELESS_SPY */
-	[SIOCGIWAP - SIOCIWFIRST] = (iw_handler) ray_get_wap,
-	[SIOCSIWESSID - SIOCIWFIRST] = (iw_handler) ray_set_essid,
-	[SIOCGIWESSID - SIOCIWFIRST] = (iw_handler) ray_get_essid,
-	[SIOCSIWRATE - SIOCIWFIRST] = (iw_handler) ray_set_rate,
-	[SIOCGIWRATE - SIOCIWFIRST] = (iw_handler) ray_get_rate,
-	[SIOCSIWRTS - SIOCIWFIRST] = (iw_handler) ray_set_rts,
-	[SIOCGIWRTS - SIOCIWFIRST] = (iw_handler) ray_get_rts,
-	[SIOCSIWFRAG - SIOCIWFIRST] = (iw_handler) ray_set_frag,
-	[SIOCGIWFRAG - SIOCIWFIRST] = (iw_handler) ray_get_frag,
+	STD_IW_HANDLER(SIOCGIWAP, ray_get_wap),
+	STD_IW_HANDLER(SIOCSIWESSID, ray_set_essid),
+	STD_IW_HANDLER(SIOCGIWESSID, ray_get_essid),
+	STD_IW_HANDLER(SIOCSIWRATE, ray_set_rate),
+	STD_IW_HANDLER(SIOCGIWRATE, ray_get_rate),
+	STD_IW_HANDLER(SIOCSIWRTS, ray_set_rts),
+	STD_IW_HANDLER(SIOCGIWRTS, ray_get_rts),
+	STD_IW_HANDLER(SIOCSIWFRAG, ray_set_frag),
+	STD_IW_HANDLER(SIOCGIWFRAG, ray_get_frag),
 };
 
 #define SIOCSIPFRAMING	SIOCIWFIRSTPRIV	/* Set framing mode */
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 7b9621d..d72f588 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1834,32 +1834,32 @@ out:
 }
 
 static const iw_handler	wl3501_handler[] = {
-	[SIOCGIWNAME	- SIOCIWFIRST] = wl3501_get_name,
-	[SIOCSIWFREQ	- SIOCIWFIRST] = wl3501_set_freq,
-	[SIOCGIWFREQ	- SIOCIWFIRST] = wl3501_get_freq,
-	[SIOCSIWMODE	- SIOCIWFIRST] = wl3501_set_mode,
-	[SIOCGIWMODE	- SIOCIWFIRST] = wl3501_get_mode,
-	[SIOCGIWSENS	- SIOCIWFIRST] = wl3501_get_sens,
-	[SIOCGIWRANGE	- SIOCIWFIRST] = wl3501_get_range,
-	[SIOCSIWSPY	- SIOCIWFIRST] = iw_handler_set_spy,
-	[SIOCGIWSPY	- SIOCIWFIRST] = iw_handler_get_spy,
-	[SIOCSIWTHRSPY	- SIOCIWFIRST] = iw_handler_set_thrspy,
-	[SIOCGIWTHRSPY	- SIOCIWFIRST] = iw_handler_get_thrspy,
-	[SIOCSIWAP	- SIOCIWFIRST] = wl3501_set_wap,
-	[SIOCGIWAP	- SIOCIWFIRST] = wl3501_get_wap,
-	[SIOCSIWSCAN	- SIOCIWFIRST] = wl3501_set_scan,
-	[SIOCGIWSCAN	- SIOCIWFIRST] = wl3501_get_scan,
-	[SIOCSIWESSID	- SIOCIWFIRST] = wl3501_set_essid,
-	[SIOCGIWESSID	- SIOCIWFIRST] = wl3501_get_essid,
-	[SIOCSIWNICKN	- SIOCIWFIRST] = wl3501_set_nick,
-	[SIOCGIWNICKN	- SIOCIWFIRST] = wl3501_get_nick,
-	[SIOCGIWRATE	- SIOCIWFIRST] = wl3501_get_rate,
-	[SIOCGIWRTS	- SIOCIWFIRST] = wl3501_get_rts_threshold,
-	[SIOCGIWFRAG	- SIOCIWFIRST] = wl3501_get_frag_threshold,
-	[SIOCGIWTXPOW	- SIOCIWFIRST] = wl3501_get_txpow,
-	[SIOCGIWRETRY	- SIOCIWFIRST] = wl3501_get_retry,
-	[SIOCGIWENCODE	- SIOCIWFIRST] = wl3501_get_encode,
-	[SIOCGIWPOWER	- SIOCIWFIRST] = wl3501_get_power,
+	STD_IW_HANDLER(SIOCGIWNAME, wl3501_get_name),
+	STD_IW_HANDLER(SIOCSIWFREQ, wl3501_set_freq),
+	STD_IW_HANDLER(SIOCGIWFREQ, wl3501_get_freq),
+	STD_IW_HANDLER(SIOCSIWMODE, wl3501_set_mode),
+	STD_IW_HANDLER(SIOCGIWMODE, wl3501_get_mode),
+	STD_IW_HANDLER(SIOCGIWSENS, wl3501_get_sens),
+	STD_IW_HANDLER(SIOCGIWRANGE, wl3501_get_range),
+	STD_IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
+	STD_IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
+	STD_IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
+	STD_IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
+	STD_IW_HANDLER(SIOCSIWAP, wl3501_set_wap),
+	STD_IW_HANDLER(SIOCGIWAP, wl3501_get_wap),
+	STD_IW_HANDLER(SIOCSIWSCAN, wl3501_set_scan),
+	STD_IW_HANDLER(SIOCGIWSCAN, wl3501_get_scan),
+	STD_IW_HANDLER(SIOCSIWESSID, wl3501_set_essid),
+	STD_IW_HANDLER(SIOCGIWESSID, wl3501_get_essid),
+	STD_IW_HANDLER(SIOCSIWNICKN, wl3501_set_nick),
+	STD_IW_HANDLER(SIOCGIWNICKN, wl3501_get_nick),
+	STD_IW_HANDLER(SIOCGIWRATE, wl3501_get_rate),
+	STD_IW_HANDLER(SIOCGIWRTS, wl3501_get_rts_threshold),
+	STD_IW_HANDLER(SIOCGIWFRAG, wl3501_get_frag_threshold),
+	STD_IW_HANDLER(SIOCGIWTXPOW, wl3501_get_txpow),
+	STD_IW_HANDLER(SIOCGIWRETRY, wl3501_get_retry),
+	STD_IW_HANDLER(SIOCGIWENCODE, wl3501_get_encode),
+	STD_IW_HANDLER(SIOCGIWPOWER, wl3501_get_power),
 };
 
 static const struct iw_handler_def wl3501_handler_def = {
-- 
1.7.0.14.g7e948
