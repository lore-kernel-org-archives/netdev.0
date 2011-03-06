From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 4/4] bnx2x: fix MaxBW configuration
Date: Sun, 6 Mar 2011 22:51:37 +0200
Message-ID: <1299444697.13442.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4092 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754505Ab1CFU6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 15:58:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Increase resolution of MaxBW algorithm to suit
Min Bandwidth configuration.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 2ac4e3c..8849699 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1617,8 +1617,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 /* CMNG constants, as derived from system spec calculations */
 /* default MIN rate in case VNIC min rate is configured to zero - 100Mbps */
 #define DEF_MIN_RATE					100
-/* resolution of the rate shaping timer - 100 usec */
-#define RS_PERIODIC_TIMEOUT_USEC			100
+/* resolution of the rate shaping timer - 400 usec */
+#define RS_PERIODIC_TIMEOUT_USEC			400
 /* number of bytes in single QM arbitration cycle -
  * coefficient for calculating the fairness timer */
 #define QM_ARB_BYTES					160000
-- 
1.7.2.2




