From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 7/7] wireless/libertas: remove trailing space in debugfs header
Date: Wed, 24 Mar 2010 19:46:35 +0100
Message-ID: <1269456395-15343-7-git-send-email-elendil@planet.nl>
References: <201003241927.12434.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>, libertas-dev@lists.infradead.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241927.12434.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Frans Pop <elendil@planet.nl>
Cc: libertas-dev@lists.infradead.org
---
 drivers/net/wireless/libertas/debugfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 587b0cb..9c3c2f8 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -74,7 +74,7 @@ static ssize_t lbs_getscantable(struct file *file, char __user *userbuf,
 		return -ENOMEM;
 
 	pos += snprintf(buf+pos, len-pos,
-		"# | ch  | rssi |       bssid       |   cap    | Qual | SSID \n");
+		"# | ch  | rssi |       bssid       |   cap    | Qual | SSID\n");
 
 	mutex_lock(&priv->lock);
 	list_for_each_entry (iter_bss, &priv->network_list, list) {
-- 
1.6.6.1
