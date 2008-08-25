From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 4/9] bnx2x: HW lock timeout
Date: Mon, 25 Aug 2008 17:24:41 +0300
Message-ID: <1219674281.19456.30.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3952 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568AbYHYOZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:25:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HW lock timeout
Increasing the lock timeout to 5 seconds instead of 1 second to minimize
the chance of failures due to timeout

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9972d0c..cb91802 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1717,8 +1717,8 @@ static int bnx2x_acquire_hw_lock(struct bnx2x *bp, u32 resource)
 		return -EEXIST;
 	}
 
-	/* Try for 1 second every 5ms */
-	for (cnt = 0; cnt < 200; cnt++) {
+	/* Try for 5 second every 5ms */
+	for (cnt = 0; cnt < 1000; cnt++) {
 		/* Try to acquire the lock */
 		REG_WR(bp, hw_lock_control_reg + 4, resource_bit);
 		lock_status = REG_RD(bp, hw_lock_control_reg);
-- 
1.5.3.2




