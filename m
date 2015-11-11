From: Colin King <colin.king@canonical.com>
Subject: [PATCH] fjes: fix inconsistent indenting
Date: Wed, 11 Nov 2015 15:22:40 +0000
Message-ID: <1447255360-31468-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Markus Elfring <elfring@users.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

minor change, indenting is one tab out.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/fjes/fjes_hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
index bb8b530..b103adb 100644
--- a/drivers/net/fjes/fjes_hw.c
+++ b/drivers/net/fjes/fjes_hw.c
@@ -599,7 +599,7 @@ int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
 		FJES_CMD_REQ_RES_CODE_BUSY) &&
 	       (timeout > 0)) {
 		msleep(200 + hw->my_epid * 20);
-			timeout -= (200 + hw->my_epid * 20);
+		timeout -= (200 + hw->my_epid * 20);
 
 		res_buf->unshare_buffer.length = 0;
 		res_buf->unshare_buffer.code = 0;
-- 
2.5.0
