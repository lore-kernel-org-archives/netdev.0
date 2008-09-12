From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 21/29][UPDATED] ixgbe: cleanup defines
Date: Thu, 11 Sep 2008 20:03:00 -0700
Message-ID: <20080912030032.6234.237.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:44161 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbYILDDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:03:05 -0400
Received: by wa-out-1112.google.com with SMTP id j37so393897waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:03:04 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2388af2..d69215e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -56,10 +56,6 @@
 #define IXGBE_MAX_RXD			   4096
 #define IXGBE_MIN_RXD			     64
 
-#define IXGBE_DEFAULT_RXQ			   1
-#define IXGBE_MAX_RXQ				   1
-#define IXGBE_MIN_RXQ				   1
-
 /* flow control */
 #define IXGBE_DEFAULT_FCRTL		0x10000
 #define IXGBE_MIN_FCRTL			   0x40
@@ -81,9 +77,6 @@
 
 #define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 
-/* How many Tx Descriptors do we need to call netif_wake_queue? */
-#define IXGBE_TX_QUEUE_WAKE 16
-
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 

