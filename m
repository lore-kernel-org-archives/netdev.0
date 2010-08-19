From: Joe Perches <joe@perches.com>
Subject: [RFC patch] include/net/cfg80211.h: wiphy_<level> messages use
 dev_printk
Date: Thu, 19 Aug 2010 12:24:08 -0700
Message-ID: <1282245848.6724.261.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding device to the wiphy logging messages could be useful.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cfg80211.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 6a98b1b..61bc007 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2439,7 +2439,7 @@ void cfg80211_cqm_rssi_notify(struct net_device *dev,
 /* wiphy_printk helpers, similar to dev_printk */
 
 #define wiphy_printk(level, wiphy, format, args...)		\
-	printk(level "%s: " format, wiphy_name(wiphy), ##args)
+	dev_printk(level, &wiphy->dev, "%s: " format, wiphy_name(wiphy), ##args)
 #define wiphy_emerg(wiphy, format, args...)			\
 	wiphy_printk(KERN_EMERG, wiphy, format, ##args)
 #define wiphy_alert(wiphy, format, args...)			\
