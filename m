From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/7] e1000e: Increase Tx timeout factor for 10Mbps
Date: Fri, 08 Aug 2008 18:36:01 -0700
Message-ID: <20080809013601.23913.15258.stgit@localhost.localdomain>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16589 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755040AbYHIBgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:36:02 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Prevent Tx hangs from happening on 10Mb flood ping by increasing the
timeout factor.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index efa9445..4573c7b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3058,7 +3058,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			case SPEED_10:
 				txb2b = 0;
 				netdev->tx_queue_len = 10;
-				adapter->tx_timeout_factor = 14;
+				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = 0;

