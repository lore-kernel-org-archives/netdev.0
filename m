From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 18/34] wan/pc300: Drop __TIME__ usage
Date: Tue,  5 Apr 2011 16:59:05 +0200
Message-ID: <1302015561-21047-19-git-send-email-mmarek@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 drivers/net/wan/pc300_drv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index f875cfa..80ae503 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3242,8 +3242,7 @@ static inline void show_version(void)
 	rcsdate++;
 	tmp = strrchr(rcsdate, ' ');
 	*tmp = '\0';
-	printk(KERN_INFO "Cyclades-PC300 driver %s %s (built %s %s)\n", 
-		rcsvers, rcsdate, __DATE__, __TIME__);
+	printk(KERN_INFO "Cyclades-PC300 driver %s %s\n", rcsvers, rcsdate);
 }				/* show_version */
 
 static const struct net_device_ops cpc_netdev_ops = {
-- 
1.7.4.1

