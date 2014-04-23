From: Jan Moskyto Matejka <mq@suse.cz>
Subject: [PATCH][linux-next] wireless: fixed bad dev_info integer type warning
Date: Wed, 23 Apr 2014 15:00:39 +0200
Message-ID: <1398258039-20512-1-git-send-email-mq@suse.cz>
Cc: Jan Moskyto Matejka <mq@suse.cz>
To: Bing Zhao <bzhao@marvell.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pointer difference (ptrdiff_t) should be formatted by %tx, not %lx.

Signed-off-by: Jan Moskyto Matejka <mq@suse.cz>
---
 drivers/net/wireless/mwifiex/pcie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 9c1f427..e04141a 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -2321,7 +2321,7 @@ static void mwifiex_pcie_fw_dump_work(struct work_struct *work)
 			if (stat != RDWR_STATUS_DONE)
 				continue;
 
-			dev_info(adapter->dev, "%s done: size=0x%lx\n",
+			dev_info(adapter->dev, "%s done: size=0x%tx\n",
 				 entry->mem_name, dbg_ptr - entry->mem_ptr);
 			memset(filename, 0, sizeof(filename));
 			memcpy(filename, name_prefix, strlen(name_prefix));
-- 
1.8.4.5
