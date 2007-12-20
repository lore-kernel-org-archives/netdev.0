From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000e: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 10:51:26 -0800
Message-ID: <20071220185125.21903.44752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parag.warudkar@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53977 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756749AbXLTTM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:12:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parag Warudkar <parag.warudkar@gmail.com>

Reduce wakeups from idle per second.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2422d16..59960d2 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3931,7 +3931,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	init_timer(&adapter->watchdog_timer);
+	init_timer_deferrable(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 

