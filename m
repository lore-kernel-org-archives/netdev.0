From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: [PATCH] net/wireless: enable wiphy device to suspend/resume asynchronously
Date: Thu, 30 Jul 2015 13:18:50 +0800
Message-ID: <55B9B3BA.6080406@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: johannes@sipsolutions.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable wiphy device to suspend/resume asynchronously. This can improve
system suspend/resume speed.

Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
---
 net/wireless/core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index 2a0bbd2..bc5e68f 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -416,6 +416,7 @@ use_default_name:
 	device_initialize(&rdev->wiphy.dev);
 	rdev->wiphy.dev.class = &ieee80211_class;
 	rdev->wiphy.dev.platform_data = rdev;
+	device_enable_async_suspend(&rdev->wiphy.dev);
 
 	INIT_LIST_HEAD(&rdev->destroy_list);
 	spin_lock_init(&rdev->destroy_list_lock);
-- 1.7.1
