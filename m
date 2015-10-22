From: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v5 14/15] net: wireless: ath: Remove unneeded variable ret returning 0
Date: Fri, 23 Oct 2015 00:27:34 +0530
Message-ID: <1445540254-4207-1-git-send-email-punitvara@gmail.com>
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove empty line suggested by Sergei

This patch is to the ath5k/eeprom.c that fixes up warning caught by
coccicheck:

Unneeded variable: "ret". Return "0" on line 980

Remove unneeded variable ret created to return zero.

Signed-off-by: Punit Vara <punitvara-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 900e72a..94bcc08 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -935,8 +935,6 @@ static const struct ieee80211_ops wcn36xx_ops = {
 
 static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 {
-	int ret = 0;
