From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net:bonding: Add missing space in bonding driver parameter description
Date: Tue,  9 Sep 2014 18:07:55 +0900
Message-ID: <1410253675-12652-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org,
	davem@davemloft.net, rdunlap@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds missing space between "interface" and "by"
in bonding module parameter description.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/bonding/bond_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f0f5eab..57912ee 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -175,7 +175,7 @@ MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to "
 				"the same MAC; 0 for none (default), "
 				"1 for active, 2 for follow");
 module_param(all_slaves_active, int, 0);
-MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface"
+MODULE_PARM_DESC(all_slaves_active, "Keep all frames received on an interface "
 				     "by setting active flag for all slaves; "
 				     "0 for never (default), 1 for always.");
 module_param(resend_igmp, int, 0);
-- 
2.1.0.60.g85f0837
