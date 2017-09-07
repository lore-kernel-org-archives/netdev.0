From: Mathieu Malaterre <malat@debian.org>
Subject: [PATCH] drivers: net: Display proper debug level up to 6
Date: Thu,  7 Sep 2017 13:24:20 +0200
Message-ID: <20170907112422.26570-1-malat@debian.org>
Cc: Mathieu Malaterre <malat@debian.org>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will make it explicit some messages are of the form:
dm9000_dbg(db, 5, ...

Signed-off-by: Mathieu Malaterre <malat@debian.org>
---
 drivers/net/ethernet/davicom/dm9000.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 16fe776ddbe5..50222b7b81f3 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -65,7 +65,7 @@ MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
  */
 static int debug;
 module_param(debug, int, 0644);
-MODULE_PARM_DESC(debug, "dm9000 debug level (0-4)");
+MODULE_PARM_DESC(debug, "dm9000 debug level (0-6)");
 
 /* DM9000 register address locking.
  *
-- 
2.11.0
