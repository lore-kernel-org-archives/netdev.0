From: Brent Taylor <motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] ath6kl: Use vmalloc for loading firmware using api1 method
Date: Fri, 16 Oct 2015 00:10:59 -0500
Message-ID: <1444972259-24260-1-git-send-email-motobud@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath6kl-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Brent Taylor <motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/init.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 6e473fa..2155739 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -673,10 +673,17 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
 		return ret;
 
 	*fw_len = fw_entry->size;
-	*fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
