From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next] ipv4: remove fib_update_nh_saddrs() declaration.
Date: Mon,  1 Jul 2013 22:19:45 +0300
Message-ID: <1372706385-30895-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:48717 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977Ab3GAQ0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 12:26:07 -0400
Received: by mail-wi0-f179.google.com with SMTP id hj3so3266633wib.6
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 09:26:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the fib_update_nh_saddrs() declaration from
include/net/ip_fib.h, as the fib_update_nh_saddrs() method was removed in 
coomit 436c3b6 ("ipv4: Invalidate nexthop cache nh_saddr more correctly").

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 include/net/ip_fib.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index aac8553..cbf2be3 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -291,7 +291,6 @@ static inline int fib_num_tclassid_users(struct net *net)
 extern int ip_fib_check_default(__be32 gw, struct net_device *dev);
 extern int fib_sync_down_dev(struct net_device *dev, int force);
 extern int fib_sync_down_addr(struct net *net, __be32 local);
-extern void fib_update_nh_saddrs(struct net_device *dev);
 extern int fib_sync_up(struct net_device *dev);
 extern void fib_select_multipath(struct fib_result *res);
 
-- 
1.8.1.4
