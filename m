From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] net: remove two duplicated include
Date: Wed, 25 Mar 2009 11:31:32 +0800
Message-ID: <20090325033132.GA7060@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:50014 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbZCYDeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 23:34:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net: remove two duplicated include

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 drivers/net/atl1c/atl1c.h |    1 -
 drivers/net/dnet.c        |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index ac11b84..e1658ef 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -45,7 +45,6 @@
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/tcp.h>
-#include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/workqueue.h>
diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 5c347f7..8a98d40 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -21,7 +21,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
-#include <linux/platform_device.h>
 
 #include "dnet.h"
 
-- 
1.5.6.3

