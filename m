From: Shawn Lin <shawn.lin@rock-chips.com>
Subject: [PATCH] mwifiex: debugfs: remove redunant check of mwifiex_dfs_dir
Date: Thu, 15 Jun 2017 16:59:25 +0800
Message-ID: <1497517165-145266-1-git-send-email-shawn.lin@rock-chips.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Shawn Lin <shawn.lin@rock-chips.com>
To: Amitkumar Karwar <amitkarwar@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucky1.263xmail.com ([211.157.147.133]:54042 "EHLO
        lucky1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdFOJBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 05:01:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

debugfs_remove already check mwifiex_dfs_dir, so remove it.

Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
---

 drivers/net/wireless/marvell/mwifiex/debugfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/debugfs.c b/drivers/net/wireless/marvell/mwifiex/debugfs.c
index ae2b69d..f6f105a 100644
--- a/drivers/net/wireless/marvell/mwifiex/debugfs.c
+++ b/drivers/net/wireless/marvell/mwifiex/debugfs.c
@@ -1046,6 +1046,5 @@
 void
 mwifiex_debugfs_remove(void)
 {
-	if (mwifiex_dfs_dir)
-		debugfs_remove(mwifiex_dfs_dir);
+	debugfs_remove(mwifiex_dfs_dir);
 }
-- 
1.9.1
