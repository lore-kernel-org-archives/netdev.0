From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] bridge: remove extern from function prototypes
Date: Thu, 26 Dec 2013 14:19:03 +0800
Message-ID: <52BBCA57.9080706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:6464 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750778Ab3LZGam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Dec 2013 01:30:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There are a mix of function prototypes with and without extern
in the kernel sources. Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler. Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/bridge/br_private.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2e77d92..458889e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -762,7 +762,7 @@ unsigned long br_timer_value(const struct timer_list *timer);
 
 /* br.c */
 #if IS_ENABLED(CONFIG_ATM_LANE)
-extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr);
+int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr);
 #endif
 
 /* br_netlink.c */
-- 
1.8.3.1
