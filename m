From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] iwlwifi: Add __printf verification
Date: Wed, 07 Mar 2012 12:23:31 -0800
Message-ID: <1331151811.2140.75.camel@joe2Laptop>
References: <1331142764-5750-1-git-send-email-wey-yi.w.guy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331142764-5750-1-git-send-email-wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Make sure that arguments match formats.
All current uses do.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/iwl-debug.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index 01b2330..42e6bbb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -34,10 +34,14 @@
 
 struct iwl_priv;
 
+__printf(4, 5)
 void __iwl_err(struct device *dev, bool rfkill_prefix, bool only_trace,
 		const char *fmt, ...);
+__printf(2, 3)
 void __iwl_warn(struct device *dev, const char *fmt, ...);
+__printf(2, 3)
 void __iwl_info(struct device *dev, const char *fmt, ...);
+__printf(2, 3)
 void __iwl_crit(struct device *dev, const char *fmt, ...);
 
 /* No matter what is m (priv, bus, trans), this will work */
@@ -47,10 +51,12 @@ void __iwl_crit(struct device *dev, const char *fmt, ...);
 #define IWL_CRIT(m, f, a...) __iwl_crit(trans(m)->dev, f, ## a)
 
 #if defined(CONFIG_IWLWIFI_DEBUG) || defined(CONFIG_IWLWIFI_DEVICE_TRACING)
+__printf(6, 7)
 void __iwl_dbg(struct iwl_shared *shared, struct device *dev,
 	       u32 level, bool limit, const char *function,
 	       const char *fmt, ...);
 #else
+__printf(6, 7)
 static inline void
 __iwl_dbg(struct iwl_shared *shared, struct device *dev,
 	  u32 level, bool limit, const char *function,


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
