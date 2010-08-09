From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 1/3] etherdevice.h: fix kernel-doc typo
Date: Mon, 9 Aug 2010 16:40:03 -0700
Message-ID: <20100809164003.39c496ee.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21593 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757160Ab0HIXnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 19:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix etherdevice.h parameter name typo in kernel-doc:

Warning(include/linux/etherdevice.h:138): No description found for parameter 'hwaddr'
Warning(include/linux/etherdevice.h:138): Excess function parameter 'addr' description in 'dev_hw_addr_random'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/linux/etherdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.35-git8.orig/include/linux/etherdevice.h
+++ linux-2.6.35-git8/include/linux/etherdevice.h
@@ -129,7 +129,7 @@ static inline void random_ether_addr(u8 
 /**
  * dev_hw_addr_random - Create random MAC and set device flag
  * @dev: pointer to net_device structure
- * @addr: Pointer to a six-byte array containing the Ethernet address
+ * @hwaddr: Pointer to a six-byte array containing the Ethernet address
  *
  * Generate random MAC to be used by a device and set addr_assign_type
  * so the state can be read by sysfs and be used by udev.
