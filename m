From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 19/20] [cosmetic] igb: unused variable warning in igb
	remove
Date: Tue, 08 Jul 2008 15:14:04 -0700
Message-ID: <20080708221343.1518.65778.stgit@localhost.localdomain>
References: <20080708220046.1518.88457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54492 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbYGHWOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:14:05 -0400
In-Reply-To: <20080708220046.1518.88457.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Wrap hw variable declaration in DCA flags to prevent unused variable
warning during compilation.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 00e2e8d..2a5303c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1360,7 +1360,9 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_DCA
 	struct e1000_hw *hw = &adapter->hw;
+#endif
 
 	/* flush_scheduled work may reschedule our watchdog task, so
 	 * explicitly disable watchdog tasks from being rescheduled  */

