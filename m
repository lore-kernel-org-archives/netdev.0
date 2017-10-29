From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] wlcore: Delete an unnecessary check statement in
 wlcore_set_beacon_template()
Date: Sun, 29 Oct 2017 21:12:41 +0100
Message-ID: <ccb3f6ab-3c39-9c34-518f-f7f36615930b@users.sourceforge.net>
References: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Eyal Reizer <eyalr@ti.com>, Iain Hunter <drhunter95@gmail.com>,
        James Minor <james.minor@ni.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Maxim Altshul <maxim.altshul@ti.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <dc2b8a7c-b4a9-2f92-12b4-a1d0d6911d7c@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 19:45:07 +0100

A goto statement jumped to a target which followed a condition check
immediately without the specification of useful actions between.
Thus remove such unnecessary source code at the end of this function.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ti/wlcore/main.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/main.c b/drivers/net/wireless/ti/wlcore/main.c
index 48380d48ef09..efea811c1c83 100644
--- a/drivers/net/wireless/ti/wlcore/main.c
+++ b/drivers/net/wireless/ti/wlcore/main.c
@@ -4085,9 +4085,6 @@ static int wlcore_set_beacon_template(struct wl1271 *wl,
 					      min_rate);
 end_bcn:
 	dev_kfree_skb(beacon);
-	if (ret < 0)
-		goto out;
-
 out:
 	return ret;
 }
-- 
2.14.3

