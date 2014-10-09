From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net: Missing @ before descriptions cause make xmldocs warning
Date: Thu,  9 Oct 2014 12:58:08 +0900
Message-ID: <1412827088-30718-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:47790 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaJID6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 23:58:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix following warning.
Warning(.//net/core/skbuff.c:4142): No description found for parameter 'header_len'
Warning(.//net/core/skbuff.c:4142): No description found for parameter 'data_len'
Warning(.//net/core/skbuff.c:4142): No description found for parameter 'max_page_order'
Warning(.//net/core/skbuff.c:4142): No description found for parameter 'errcode'
Warning(.//net/core/skbuff.c:4142): No description found for parameter 'gfp_mask'

Acutually the descriptions exist, but missing "@" in front.

This problem start to happen when following commit was merged
into Linus's tree during 3.18-rc1 merge period.
commit 2e4e44107176d552f8bb1bb76053e850e3809841
net: add alloc_skb_with_frags() helper

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/core/skbuff.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7b3df0d..a30d750 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4126,11 +4126,11 @@ EXPORT_SYMBOL(skb_vlan_untag);
 /**
  * alloc_skb_with_frags - allocate skb with page frags
  *
- * header_len: size of linear part
- * data_len: needed length in frags
- * max_page_order: max page order desired.
- * errcode: pointer to error code if any
- * gfp_mask: allocation mask
+ * @header_len: size of linear part
+ * @data_len: needed length in frags
+ * @max_page_order: max page order desired.
+ * @errcode: pointer to error code if any
+ * @gfp_mask: allocation mask
  *
  * This can be used to allocate a paged skb, given a maximal order for frags.
  */
-- 
2.1.2.374.g63a4513
