From: Rami Rosen <ramirose@gmail.com>
Subject: [net-next patch] vxlan: remove unused variable.
Date: Sat, 17 Nov 2012 16:08:07 +0200
Message-ID: <1353161287-22493-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37748 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522Ab2KQMIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 07:08:31 -0500
Received: by mail-wi0-f172.google.com with SMTP id hj6so2602913wib.1
        for <netdev@vger.kernel.org>; Sat, 17 Nov 2012 04:08:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes addrexceeded member from vxlan_dev struct as it is unused.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/vxlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 9814d67..288ad3a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -117,7 +117,6 @@ struct vxlan_dev {
 	spinlock_t	  hash_lock;
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
-	unsigned int	  addrexceeded;
 
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
-- 
1.7.11.7
