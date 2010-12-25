From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 03/15] e1000e: checkpatch error - trailing statements
Date: Fri, 24 Dec 2010 22:06:02 -0800
Message-ID: <1293257174-15498-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271Ab0LYGGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:06:51 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

ERROR: trailing statements should be on next line

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/es2lan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 24f8ac9..79da646 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -426,8 +426,8 @@ static void e1000_release_swfw_sync_80003es2lan(struct e1000_hw *hw, u16 mask)
 {
 	u32 swfw_sync;
 
-	while (e1000e_get_hw_semaphore(hw) != 0);
-	/* Empty */
+	while (e1000e_get_hw_semaphore(hw) != 0)
+		; /* Empty */
 
 	swfw_sync = er32(SW_FW_SYNC);
 	swfw_sync &= ~mask;
-- 
1.7.3.4

