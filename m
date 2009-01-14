From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 14/34]bnx2x: Missing brackets
Date: Wed, 14 Jan 2009 18:43:24 +0200
Message-ID: <1231951404.11301.135.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761123AbZANQoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calculation bug due to missing brackets

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index a1d8ca5..27a9be6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2936,7 +2936,7 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 #define ADD_64(s_hi, a_hi, s_lo, a_lo) \
 	do { \
 		s_lo += a_lo; \
-		s_hi += a_hi + (s_lo < a_lo) ? 1 : 0; \
+		s_hi += a_hi + ((s_lo < a_lo) ? 1 : 0); \
 	} while (0)
 
 /* difference = minuend - subtrahend */
-- 
1.5.4.3




