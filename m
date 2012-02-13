From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/8] tg3: Eliminate unneeded prototype
Date: Mon, 13 Feb 2012 12:20:11 -0800
Message-ID: <1329164412-24566-8-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3680 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757968Ab2BMUVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:21:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates the unneeded tg3_halt_cpu() prototype and moves
the tg3_setup_phy() prototype closer to where it is needed.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index cc09217..b89c932 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2709,9 +2709,6 @@ static int tg3_5700_link_polarity(struct tg3 *tp, u32 speed)
 	return 0;
 }
 
-static int tg3_setup_phy(struct tg3 *, int);
-static int tg3_halt_cpu(struct tg3 *, u32);
-
 static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
 	u32 val;
@@ -3514,6 +3511,8 @@ static int tg3_power_up(struct tg3 *tp)
 	return err;
 }
 
+static int tg3_setup_phy(struct tg3 *, int);
+
 static int tg3_power_down_prepare(struct tg3 *tp)
 {
 	u32 misc_host_ctrl;
-- 
1.7.3.4
