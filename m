From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] wireless: ipw2x00: make iw_handler_def const
Date: Wed, 23 Aug 2017 18:06:42 +0530
Message-ID: <1503491802-1361-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, stas.yakovlev@gmail.com,
        kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only stored in the const field of a
net_device structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c | 4 ++--
 drivers/net/wireless/intel/ipw2x00/ipw2200.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index 77f3f92..19c442c 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -340,7 +340,7 @@ static int ipw2100_ucode_download(struct ipw2100_priv *priv,
 				  struct ipw2100_fw *fw);
 static void ipw2100_wx_event_work(struct work_struct *work);
 static struct iw_statistics *ipw2100_wx_wireless_stats(struct net_device *dev);
-static struct iw_handler_def ipw2100_wx_handler_def;
+static const struct iw_handler_def ipw2100_wx_handler_def;
 
 static inline void read_register(struct net_device *dev, u32 reg, u32 * val)
 {
@@ -8273,7 +8273,7 @@ static struct iw_statistics *ipw2100_wx_wireless_stats(struct net_device *dev)
 	return (struct iw_statistics *)NULL;
 }
 
-static struct iw_handler_def ipw2100_wx_handler_def = {
+static const struct iw_handler_def ipw2100_wx_handler_def = {
 	.standard = ipw2100_wx_handlers,
 	.num_standard = ARRAY_SIZE(ipw2100_wx_handlers),
 	.num_private = ARRAY_SIZE(ipw2100_private_handler),
diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index c311b1a..7194a18 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -10008,7 +10008,7 @@ enum {
 #endif
 };
 
-static struct iw_handler_def ipw_wx_handler_def = {
+static const struct iw_handler_def ipw_wx_handler_def = {
 	.standard = ipw_wx_handlers,
 	.num_standard = ARRAY_SIZE(ipw_wx_handlers),
 	.num_private = ARRAY_SIZE(ipw_priv_handler),
-- 
1.9.1
