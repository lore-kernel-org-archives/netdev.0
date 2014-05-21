From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: add required include
Date: Wed, 21 May 2014 05:01:02 -0700
Message-ID: <1400673673-31626-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20362 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752326AbaEUMB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:26 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

On some architectures, this header must be explicitly included.

Change-ID: I4bc2eb0531956a7b676489f79d347d55cfe12421
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 4 ----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 1 +
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index a46571c..ef5bb11 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -97,10 +97,6 @@
 #define STRINGIFY(foo)  #foo
 #define XSTRINGIFY(bar) STRINGIFY(bar)
 
-#ifndef ARCH_HAS_PREFETCH
-#define prefetch(X)
-#endif
-
 #define I40E_RX_DESC(R, i)			\
 	((ring_is_16byte_desc_enabled(R))	\
 		? (union i40e_32byte_rx_desc *)	\
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index ece7ae9..8d0ef44 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -24,6 +24,7 @@
  *
  ******************************************************************************/
 
+#include <linux/prefetch.h>
 #include "i40e.h"
 #include "i40e_prototype.h"
 
-- 
1.9.0
