From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next] net: core: fix kerneldoc comment
Date: Wed,  4 Oct 2017 13:56:50 +0200
Message-ID: <20171004115650.6406-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:52668 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751566AbdJDL4c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 07:56:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/core/dev.c:1306: warning: No description found for parameter 'name'
net/core/dev.c:1306: warning: Excess function parameter 'alias' description in 'dev_get_alias'

Fixes: 6c5570016b97 ("net: core: decouple ifalias get/set from rtnl lock")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1770097cfd86..454f05441546 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1295,7 +1295,7 @@ int dev_set_alias(struct net_device *dev, const char *alias, size_t len)
 /**
  *	dev_get_alias - get ifalias of a device
  *	@dev: device
- *	@alias: buffer to store name of ifalias
+ *	@name: buffer to store name of ifalias
  *	@len: size of buffer
  *
  *	get ifalias for a device.  Caller must make sure dev cannot go
-- 
2.13.6
