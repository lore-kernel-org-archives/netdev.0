From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] eth: fix new kernel-doc warning
Date: Wed, 12 Jan 2011 16:50:51 -0800
Message-ID: <20110112165051.153246cb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27495 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755961Ab1AMAvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 19:51:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix new kernel-doc warning (copy-paste typo):

Warning(net/ethernet/eth.c:366): No description found for parameter 'rxqs'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/ethernet/eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.37-git9.orig/net/ethernet/eth.c
+++ linux-2.6.37-git9/net/ethernet/eth.c
@@ -351,7 +351,7 @@ EXPORT_SYMBOL(ether_setup);
  * @sizeof_priv: Size of additional driver-private structure to be allocated
  *	for this Ethernet device
  * @txqs: The number of TX queues this device has.
- * @txqs: The number of RX queues this device has.
+ * @rxqs: The number of RX queues this device has.
  *
  * Fill in the fields of the device structure with Ethernet-generic
  * values. Basically does everything except registering the device.
