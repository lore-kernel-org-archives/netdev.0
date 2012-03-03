From: David Miller <davem@davemloft.net>
Subject: mdio.h: Include linux/types.h
Date: Sat, 03 Mar 2012 15:07:47 -0500 (EST)
Message-ID: <20120303.150747.1442564440565400238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753505Ab2CCUHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 15:07:49 -0500
Received: from localhost (cpe-66-65-56-15.nyc.res.rr.com [66.65.56.15])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q23K7lLr023016
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Sat, 3 Mar 2012 12:07:48 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fixes:

/home/davem/src/GIT/net-next/usr/include/linux/mdio.h:271: found __[us]{8,16,32,64} type without #include <linux/types.h>

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/mdio.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index ec90da7..dfb9479 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -10,6 +10,7 @@
 #ifndef __LINUX_MDIO_H__
 #define __LINUX_MDIO_H__
 
+#include <linux/types.h>
 #include <linux/mii.h>
 
 /* MDIO Manageable Devices (MMDs). */
-- 
1.7.7.6
