From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 19/25] ixgb: cleanup checkpatch suggestions that are
	relevant
Date: Tue, 08 Jul 2008 15:52:38 -0700
Message-ID: <20080708225238.6925.3202.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6794 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754721AbYGHWwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:39 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_param.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 107ef48..169636a 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -363,7 +363,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.high_water = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
@@ -383,7 +383,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.low_water = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
@@ -404,7 +404,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 			adapter->hw.fc.pause_time = opt.def;
 		}
 		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
@@ -412,7 +412,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk (KERN_INFO
+			printk(KERN_INFO
 				"RxFCHighThresh must be >= (RxFCLowThresh + 8), "
 				"Using Defaults\n");
 			adapter->hw.fc.high_water = DEFAULT_FCRTH;

