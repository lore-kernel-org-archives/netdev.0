From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 5/9] ps3_gelic: remove unnecessary break after goto
Date: Sat, 12 Jul 2014 20:09:44 +0200
Message-ID: <1405188597-2815-6-git-send-email-fabf@skynet.be>
References: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405188597-2815-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index d568af1..2553ed5 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -723,13 +723,10 @@ static int gelic_wl_get_scan(struct net_device *netdev,
 		/* If a scan in progress, caller should call me again */
 		ret = -EAGAIN;
 		goto out;
-		break;
-
 	case GELIC_WL_SCAN_STAT_INIT:
 		/* last scan request failed or never issued */
 		ret = -ENODEV;
 		goto out;
-		break;
 	case GELIC_WL_SCAN_STAT_GOT_LIST:
 		/* ok, use current list */
 		break;
-- 
1.9.1
