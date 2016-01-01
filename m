From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/6] wl1251: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:54 +0800
Message-ID: <9a028ab8d643492c36d42d9d89d212471d12f966.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
In-Reply-To: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
References: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/wireless/ti/wl1251/ps.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl1251/ps.c b/drivers/net/wireless/ti/wl1251/ps.c
index b9e27b9..fa01b0a 100644
--- a/drivers/net/wireless/ti/wl1251/ps.c
+++ b/drivers/net/wireless/ti/wl1251/ps.c
@@ -32,7 +32,7 @@ void wl1251_elp_work(struct work_struct *work)
 	struct delayed_work *dwork;
 	struct wl1251 *wl;
 
-	dwork = container_of(work, struct delayed_work, work);
+	dwork = to_delayed_work(work);
 	wl = container_of(dwork, struct wl1251, elp_work);
 
 	wl1251_debug(DEBUG_PSM, "elp work");
-- 
2.5.0
