From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 3/5] net: de4x5: constify eisa_device_id
Date: Sat, 19 Aug 2017 12:22:44 +0530
Message-ID: <1503125564-15193-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-parisc@vger.kernel.org
To: davem@davemloft.net, johannes.berg@intel.com, jarod@redhat.com
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eisa_device_id are not supposed to change at runtime. All functions
working with eisa_device_id provided by <linux/eisa.h> work with
const eisa_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 47be501..0affee9 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2094,7 +2094,7 @@ static int de4x5_eisa_remove(struct device *device)
 	return 0;
 }
 
-static struct eisa_device_id de4x5_eisa_ids[] = {
+static const struct eisa_device_id de4x5_eisa_ids[] = {
         { "DEC4250", 0 },	/* 0 is the board name index... */
         { "" }
 };
-- 
2.7.4

