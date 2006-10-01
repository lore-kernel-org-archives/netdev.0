From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/3][ATM]: [ambassador] Change the return type to reflect reality
Date: Sun, 01 Oct 2006 11:17:43 -0400
Message-ID: <200610011517.k91FHi1p006386@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:46225 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750962AbWJAPR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 11:17:58 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [ambassador] Change the return type to reflect reality

Signed-off-by: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit d7b1207f84d681df2e46c6f22ca153eb7f0944cb
tree 9204a7e7f6812bd683a0079a9a9177ec400fadbd
parent 339d365266211690a446773e3eb9d864637a71bb
author Jeff Garzik <jeff@garzik.org> Sun, 01 Oct 2006 10:23:44 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sun, 01 Oct 2006 10:23:44 -0400

 drivers/atm/ambassador.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 4521a24..da599e6 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -915,8 +915,8 @@ #endif
 
 /********** make rate (not quite as much fun as Horizon) **********/
 
-static unsigned int make_rate (unsigned int rate, rounding r,
-			       u16 * bits, unsigned int * actual) {
+static int make_rate (unsigned int rate, rounding r,
+		      u16 * bits, unsigned int * actual) {
   unsigned char exp = -1; // hush gcc
   unsigned int man = -1;  // hush gcc
   
