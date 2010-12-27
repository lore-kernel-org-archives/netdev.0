From: David Sterba <dsterba@suse.cz>
Subject: [PATCH] tg3: fix return value check in tg3_read_vpd()
Date: Mon, 27 Dec 2010 18:31:34 +0100
Message-ID: <1293471094-28976-1-git-send-email-dsterba@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Sterba <dsterba@suse.cz>,
	Michael Chan <mchan@broadcom.com>
To: mcarlson@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CC: Matt Carlson <mcarlson@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
Signed-off-by: David Sterba <dsterba@suse.cz>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30ccbb6..6f97b7b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12658,7 +12658,7 @@ static void __devinit tg3_read_vpd(struct tg3 *tp)
 			cnt = pci_read_vpd(tp->pdev, pos,
 					   TG3_NVM_VPD_LEN - pos,
 					   &vpd_data[pos]);
-			if (cnt == -ETIMEDOUT || -EINTR)
+			if (cnt == -ETIMEDOUT || cnt == -EINTR)
 				cnt = 0;
 			else if (cnt < 0)
 				goto out_not_found;
-- 
1.7.3.4.626.g73e7b
