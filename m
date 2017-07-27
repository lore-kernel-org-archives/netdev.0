From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wl3501_cs: fix spelling mistake: "Insupported" -> "Unsupported"
Date: Thu, 27 Jul 2017 23:09:54 +0100
Message-ID: <20170727220954.12105-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in printk message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/wl3501_cs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index acec0d9ec422..da62220b9c01 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -965,7 +965,7 @@ static inline void wl3501_md_ind_interrupt(struct net_device *dev,
 			    &addr4, sizeof(addr4));
 	if (!(addr4[0] == 0xAA && addr4[1] == 0xAA &&
 	      addr4[2] == 0x03 && addr4[4] == 0x00)) {
-		printk(KERN_INFO "Insupported packet type!\n");
+		printk(KERN_INFO "Unsupported packet type!\n");
 		return;
 	}
 	pkt_len = sig.size + 12 - 24 - 4 - 6;
-- 
2.11.0
