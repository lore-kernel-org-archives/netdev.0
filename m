From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 13/20] net/core/dev.c: use LIST_HEAD instead of LIST_HEAD_INIT
Date: Fri,  7 Dec 2007 00:01:26 +0800
Message-ID: <1196956886-5681-1-git-send-email-crquan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:54382 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469AbXLFQBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 11:01:54 -0500
Received: by rv-out-0910.google.com with SMTP id k20so306385rvb
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 08:01:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

single list_head variable initialized with LIST_HEAD_INIT could almost
always can be replaced with LIST_HEAD declaration, this shrinks the code
and looks better.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 86d6261..7626db4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3501,7 +3501,7 @@ static int dev_new_index(struct net *net)
 
 /* Delayed registration/unregisteration */
 static DEFINE_SPINLOCK(net_todo_list_lock);
-static struct list_head net_todo_list = LIST_HEAD_INIT(net_todo_list);
+static LIST_HEAD(net_todo_list);
 
 static void net_set_todo(struct net_device *dev)
 {
-- 
1.5.3.4

