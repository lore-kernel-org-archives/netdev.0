From: subashab@codeaurora.org
Subject: [PATCH net-next] dev: Spelling fix in comments
Date: Fri, 24 Jul 2015 03:03:29 -0000
Message-ID: <22a65bcbc60d78e3b953b79b6f30d319.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38796 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754306AbbGXDDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 23:03:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following typo
- unchainged -> unchanged

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 net/core/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 488ba6c..44d1384 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4986,7 +4986,7 @@ EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
  * Gets the next netdev_adjacent->private from the dev's lower neighbour
  * list, starting from iter position. The caller must hold either hold the
  * RTNL lock or its own locking that guarantees that the neighbour lower
- * list will remain unchainged.
+ * list will remain unchanged.
  */
 void *netdev_lower_get_next_private(struct net_device *dev,
 				    struct list_head **iter)
@@ -5041,7 +5041,7 @@ EXPORT_SYMBOL(netdev_lower_get_next_private_rcu);
  * Gets the next netdev_adjacent from the dev's lower neighbour
  * list, starting from iter position. The caller must hold RTNL lock or
  * its own locking that guarantees that the neighbour lower
- * list will remain unchainged.
+ * list will remain unchanged.
  */
 void *netdev_lower_get_next(struct net_device *dev, struct list_head **iter)
 {
--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
