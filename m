From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net/core: Fix warning while make xmldocs caused by dev.c
Date: Sat, 14 Feb 2015 22:26:34 +0900
Message-ID: <1423920394-26652-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: monis@mellanox.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix following warning wile make xmldocs.

  Warning(.//net/core/dev.c:5345): No description found
  for parameter 'bonding_info'
  Warning(.//net/core/dev.c:5345): Excess function parameter
  'netdev_bonding_info' description in 'netdev_bonding_info_change'

This warning starts to appear after following patch was added
into Linus's tree during merger period.

commit 61bd3857ff2c7daf756d49b41e6277bbdaa8f789
net/core: Add event for a change in slave state

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d030575..2e8fcb0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5335,7 +5335,7 @@ EXPORT_SYMBOL(netdev_upper_dev_unlink);
 /**
  * netdev_bonding_info_change - Dispatch event about slave change
  * @dev: device
- * @netdev_bonding_info: info to dispatch
+ * @bonding_info: info to dispatch
  *
  * Send NETDEV_BONDING_INFO to netdev notifiers with info.
  * The caller must hold the RTNL lock.
-- 
2.3.0
