From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/6] e1000: remove changelog in driver
Date: Tue, 23 May 2006 14:08:49 -0700
Message-ID: <20060523210849.18540.26478.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:62469 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932256AbWEWVDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:51 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This honours the request to remove the changelog in the driver code.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |   39 ---------------------------------------
 1 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ccbe342..95069ac 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -29,45 +29,6 @@
 
 #include "e1000.h"
 
-/* Change Log
- * 7.0.33      3-Feb-2006
- *   o Added another fix for the pass false carrier bit
- * 7.0.32      24-Jan-2006
- *   o Need to rebuild with noew version number for the pass false carrier 
- *     fix in e1000_hw.c
- * 7.0.30      18-Jan-2006
- *   o fixup for tso workaround to disable it for pci-x
- *   o fix mem leak on 82542
- *   o fixes for 10 Mb/s connections and incorrect stats
- * 7.0.28      01/06/2006
- *   o hardware workaround to only set "speed mode" bit for 1G link.
- * 7.0.26      12/23/2005
- *   o wake on lan support modified for device ID 10B5
- *   o fix dhcp + vlan issue not making it to the iAMT firmware
- * 7.0.24      12/9/2005
- *   o New hardware support for the Gigabit NIC embedded in the south bridge
- *   o Fixes to the recycling logic (skb->tail) from IBM LTC
- * 6.3.9	12/16/2005
- *   o incorporate fix for recycled skbs from IBM LTC
- * 6.3.7	11/18/2005
- *   o Honor eeprom setting for enabling/disabling Wake On Lan
- * 6.3.5 	11/17/2005
- *   o Fix memory leak in rx ring handling for PCI Express adapters
- * 6.3.4	11/8/05
- *   o Patch from Jesper Juhl to remove redundant NULL checks for kfree
- * 6.3.2	9/20/05
- *   o Render logic that sets/resets DRV_LOAD as inline functions to 
- *     avoid code replication. If f/w is AMT then set DRV_LOAD only when
- *     network interface is open.
- *   o Handle DRV_LOAD set/reset in cases where AMT uses VLANs.
- *   o Adjust PBA partioning for Jumbo frames using MTU size and not
- *     rx_buffer_len
- * 6.3.1	9/19/05
- *   o Use adapter->tx_timeout_factor in Tx Hung Detect logic 
- *      (e1000_clean_tx_irq)
- *   o Support for 8086:10B5 device (Quad Port)
- */
-
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #ifndef CONFIG_E1000_NAPI



--
Auke Kok <auke-jan.h.kok@intel.com>
