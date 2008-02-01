From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/6] igb: remove unneeded declaration shadowing earlier one
Date: Fri, 01 Feb 2008 08:21:49 -0800
Message-ID: <20080201162149.29347.59004.stgit@localhost.localdomain>
References: <20080201162118.29347.13268.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55260 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758128AbYBAQWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 11:22:37 -0500
In-Reply-To: <20080201162118.29347.13268.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes a sparse warning.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f3c144d..d4eb8e2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -438,7 +438,6 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	if (adapter->msix_entries) {
 		err = igb_request_msix(adapter);
 		if (!err) {
-			struct e1000_hw *hw = &adapter->hw;
 			/* enable IAM, auto-mask,
 			 * DO NOT USE EIAME or IAME in legacy mode */
 			wr32(E1000_IAM, IMS_ENABLE_MASK);

