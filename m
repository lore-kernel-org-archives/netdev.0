From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 04/12] ixgbe: Add SR-IOV feature enablement code
Date: Tue, 08 Dec 2009 14:14:16 -0800
Message-ID: <20091208221415.28373.88491.stgit@localhost.localdomain>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:38943 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966698AbZLHWO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:14:27 -0500
In-Reply-To: <20091208221258.28373.16663.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Adds code to the core 82599 module to support SR-IOV features of the 82599
network controller

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5383405..f45b9b4 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -31,6 +31,7 @@
 
 #include "ixgbe.h"
 #include "ixgbe_phy.h"
+#include "ixgbe_mbx.h"
 
 #define IXGBE_82599_MAX_TX_QUEUES 128
 #define IXGBE_82599_MAX_RX_QUEUES 128
@@ -951,8 +952,6 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 
 	msleep(50);
 
-
-
 	/*
 	 * Store the original AUTOC/AUTOC2 values if they have not been
 	 * stored off yet.  Otherwise restore the stored original
@@ -2655,4 +2654,5 @@ struct ixgbe_info ixgbe_82599_info = {
 	.mac_ops                = &mac_ops_82599,
 	.eeprom_ops             = &eeprom_ops_82599,
 	.phy_ops                = &phy_ops_82599,
+	.mbx_ops                = &mbx_ops_82599,
 };

