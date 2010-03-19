From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 6/9] drivers/net/wireless: Use IW_HANDLER macro
Date: Thu, 18 Mar 2010 18:29:37 -0700
Message-ID: <7ddce96249c2e7016a59f99e3e2860f948a2a330.1268961559.git.joe@perches.com>
References: <cover.1268961559.git.joe@perches.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1268961559.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert direct uses of [ (foo - SIOCIWFIRST) , fn)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ray_cs.c    |   40 ++++++++++++++--------------
 drivers/net/wireless/wl3501_cs.c |   52 +++++++++++++++++++-------------------
 2 files changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 84c530a..a42ee01 100644
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
+	IW_HANDLER(SIOCSIWCOMMIT, (iw_handler)ray_commit),
+	IW_HANDLER(SIOCGIWNAME, (iw_handler)ray_get_name),
+	IW_HANDLER(SIOCSIWFREQ, (iw_handler)ray_set_freq),
+	IW_HANDLER(SIOCGIWFREQ, (iw_handler)ray_get_freq),
+	IW_HANDLER(SIOCSIWMODE, (iw_handler)ray_set_mode),
+	IW_HANDLER(SIOCGIWMODE, (iw_handler)ray_get_mode),
+	IW_HANDLER(SIOCGIWRANGE, (iw_handler)ray_get_range),
 #ifdef WIRELESS_SPY
-	[SIOCSIWSPY - SIOCIWFIRST] = (iw_handler) iw_handler_set_spy,
-	[SIOCGIWSPY - SIOCIWFIRST] = (iw_handler) iw_handler_get_spy,
-	[SIOCSIWTHRSPY - SIOCIWFIRST] = (iw_handler) iw_handler_set_thrspy,
-	[SIOCGIWTHRSPY - SIOCIWFIRST] = (iw_handler) iw_handler_get_thrspy,
+	IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
+	IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
+	IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
+	IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
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
+	IW_HANDLER(SIOCGIWAP, (iw_handler)ray_get_wap),
+	IW_HANDLER(SIOCSIWESSID, (iw_handler)ray_set_essid),
+	IW_HANDLER(SIOCGIWESSID, (iw_handler)ray_get_essid),
+	IW_HANDLER(SIOCSIWRATE, (iw_handler)ray_set_rate),
+	IW_HANDLER(SIOCGIWRATE, (iw_handler)ray_get_rate),
+	IW_HANDLER(SIOCSIWRTS, (iw_handler)ray_set_rts),
+	IW_HANDLER(SIOCGIWRTS, (iw_handler)ray_get_rts),
+	IW_HANDLER(SIOCSIWFRAG, (iw_handler)ray_set_frag),
+	IW_HANDLER(SIOCGIWFRAG, (iw_handler)ray_get_frag),
 };
 
 #define SIOCSIPFRAMING	SIOCIWFIRSTPRIV	/* Set framing mode */
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 7b9621d..65dd502 100644
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
+	IW_HANDLER(SIOCGIWNAME, wl3501_get_name),
+	IW_HANDLER(SIOCSIWFREQ, wl3501_set_freq),
+	IW_HANDLER(SIOCGIWFREQ, wl3501_get_freq),
+	IW_HANDLER(SIOCSIWMODE, wl3501_set_mode),
+	IW_HANDLER(SIOCGIWMODE, wl3501_get_mode),
+	IW_HANDLER(SIOCGIWSENS, wl3501_get_sens),
+	IW_HANDLER(SIOCGIWRANGE, wl3501_get_range),
+	IW_HANDLER(SIOCSIWSPY, iw_handler_set_spy),
+	IW_HANDLER(SIOCGIWSPY, iw_handler_get_spy),
+	IW_HANDLER(SIOCSIWTHRSPY, iw_handler_set_thrspy),
+	IW_HANDLER(SIOCGIWTHRSPY, iw_handler_get_thrspy),
+	IW_HANDLER(SIOCSIWAP, wl3501_set_wap),
+	IW_HANDLER(SIOCGIWAP, wl3501_get_wap),
+	IW_HANDLER(SIOCSIWSCAN, wl3501_set_scan),
+	IW_HANDLER(SIOCGIWSCAN, wl3501_get_scan),
+	IW_HANDLER(SIOCSIWESSID, wl3501_set_essid),
+	IW_HANDLER(SIOCGIWESSID, wl3501_get_essid),
+	IW_HANDLER(SIOCSIWNICKN, wl3501_set_nick),
+	IW_HANDLER(SIOCGIWNICKN, wl3501_get_nick),
+	IW_HANDLER(SIOCGIWRATE, wl3501_get_rate),
+	IW_HANDLER(SIOCGIWRTS, wl3501_get_rts_threshold),
+	IW_HANDLER(SIOCGIWFRAG, wl3501_get_frag_threshold),
+	IW_HANDLER(SIOCGIWTXPOW, wl3501_get_txpow),
+	IW_HANDLER(SIOCGIWRETRY, wl3501_get_retry),
+	IW_HANDLER(SIOCGIWENCODE, wl3501_get_encode),
+	IW_HANDLER(SIOCGIWPOWER, wl3501_get_power),
 };
 
 static const struct iw_handler_def wl3501_handler_def = {
-- 
1.7.0.14.g7e948
