From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [linux-next] net: Fix typo in skb_fclone_busy
Date: Sun, 13 Dec 2015 16:53:02 +0900
Message-ID: <1449993182-20759-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix a typo found within comment of skb_fclone_busy.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 include/linux/skbuff.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9b9b9ea..af4f6ac 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -833,7 +833,7 @@ struct sk_buff_fclones {
  *	skb_fclone_busy - check if fclone is busy
  *	@skb: buffer
  *
- * Returns true is skb is a fast clone, and its clone is not freed.
+ * Returns true if skb is a fast clone, and its clone is not freed.
  * Some drivers call skb_orphan() in their ndo_start_xmit(),
  * so we also check that this didnt happen.
  */
-- 
2.6.4.442.g545299f
