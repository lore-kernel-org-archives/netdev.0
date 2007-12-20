From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 10:51:36 -0800
Message-ID: <20071220185136.21903.73382.stgit@localhost.localdomain>
References: <20071220185125.21903.44752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, parag.warudkar@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19483 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbXLTSwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 13:52:09 -0500
In-Reply-To: <20071220185125.21903.44752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parag Warudkar <parag.warudkar@gmail.com>

Reduces wakeups from idle per second.

Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 599153d..6af86fa 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1066,7 +1066,7 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
 	adapter->tx_fifo_stall_timer.data = (unsigned long) adapter;
 
-	init_timer(&adapter->watchdog_timer);
+	init_timer_deferrable(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &e1000_watchdog;
 	adapter->watchdog_timer.data = (unsigned long) adapter;
 

