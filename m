From: Sam Bristow <sam.bristow@gmail.com>
Subject: [PATCH] include: net: Add parameter desc to fix warning when generating docs
Date: Fri,  5 Jul 2013 09:18:21 +1200
Message-ID: <1372972701-18323-1-git-send-email-sam.bristow@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Sam Bristow <sam.bristow@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'make htmldocs' was generating a warning about a missing parameter description
for gfp.
---
 include/net/cfg80211.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 26b5b69..159e070 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -4153,6 +4153,7 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
  * cfg80211_crit_proto_stopped() - indicate critical protocol stopped by driver.
  *
  * @wdev: the wireless device for which critical protocol is stopped.
+ * @gfp: allocation flags
  *
  * This function can be called by the driver to indicate it has reverted
  * operation back to normal. One reason could be that the duration given
-- 
1.8.3.1
