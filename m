From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: Fix typo ! &
Date: Mon, 29 Oct 2007 10:50:05 -0700
Message-ID: <20071029175005.26219.60547.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13407 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981AbXJ2Rua (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 13:50:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roel Kluin <12o3l@tiscali.nl>

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index cf70522..14141a5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -283,7 +283,7 @@ static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
 			adapter->flags &= ~FLAG_HAS_WOL;
 		/* quad ports only support WoL on port A */
 		if (adapter->flags & FLAG_IS_QUAD_PORT &&
-		    (!adapter->flags & FLAG_IS_QUAD_PORT_A))
+		    (!(adapter->flags & FLAG_IS_QUAD_PORT_A)))
 			adapter->flags &= ~FLAG_HAS_WOL;
 		break;
 
