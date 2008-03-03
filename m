From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/4] ixgbe: fix typo in speed mesage
Date: Mon, 03 Mar 2008 14:37:42 -0800
Message-ID: <20080303223742.16344.6855.stgit@localhost.localdomain>
References: <20080303223731.16344.94975.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44045 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbYCCWhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:37:43 -0500
In-Reply-To: <20080303223731.16344.94975.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 23d0a4a..c2095ce 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2133,7 +2133,7 @@ static void ixgbe_watchdog(unsigned long data)
 				(link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
 				 "10 Gbps" :
 				 (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-				  "1 Gpbs" : "unknown speed")),
+				  "1 Gbps" : "unknown speed")),
 				((FLOW_RX && FLOW_TX) ? "RX/TX" :
 				 (FLOW_RX ? "RX" :
 				 (FLOW_TX ? "TX" : "None"))));

