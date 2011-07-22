From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: remove ifdef check for non-existent define
Date: Thu, 21 Jul 2011 23:09:09 -0700
Message-ID: <1311314951-11142-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753451Ab1GVGJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 02:09:19 -0400
In-Reply-To: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a222af3..358f6c9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6021,9 +6021,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	       (flow_tx ? "TX" : "None"))));
 
 	netif_carrier_on(netdev);
-#ifdef HAVE_IPLINK_VF_CONFIG
 	ixgbe_check_vf_rate_limit(adapter);
-#endif /* HAVE_IPLINK_VF_CONFIG */
 }
 
 /**
-- 
1.7.6

