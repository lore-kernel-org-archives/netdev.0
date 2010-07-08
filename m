From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Remove unused field left from mis-merge
Date: Fri, 09 Jul 2010 00:36:32 +0100
Message-ID: <1278632192.16013.309.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26013 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab0GHXgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 19:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit eedc765ca4b19a41cf0b921a492ac08d640060d1 merged changes from
net-2.6 that added and then removed efx_nic::port_num, which was also
added in net-next-2.6.  The end result should be that it is removed,
since it is now unused.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index bab836c..64e7caa 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -622,7 +622,6 @@ union efx_multicast_hash {
  * struct efx_nic - an Efx NIC
  * @name: Device name (net device name or bus id before net device registered)
  * @pci_dev: The PCI device
- * @port_num: Index of this host port within the controller
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
@@ -708,7 +707,6 @@ union efx_multicast_hash {
 struct efx_nic {
 	char name[IFNAMSIZ];
 	struct pci_dev *pci_dev;
-	unsigned port_num;
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

