From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net-sysfs: fix missing <linux/of_net.h>
Date: Tue,  7 Jun 2016 19:27:51 +0100
Message-ID: <1465324071-7337-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:37798 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751946AbcFGS2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 14:28:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The of_find_net_device_by_node() function is defined in
<linux/of_net.h> but not included in the .c file that
implements it. Fix the following warning by including the
header:

net/core/net-sysfs.c:1494:19: warning: symbol 'of_find_net_device_by_node' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/core/net-sysfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2b3f76f..7a0b616 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -24,6 +24,7 @@
 #include <linux/jiffies.h>
 #include <linux/pm_runtime.h>
 #include <linux/of.h>
+#include <linux/of_net.h>
 
 #include "net-sysfs.h"
 
-- 
2.8.1
