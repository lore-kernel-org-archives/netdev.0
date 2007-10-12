From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/6] sky2: fiber advertise bits initialization (trivial)
Date: Thu, 11 Oct 2007 18:19:55 -0700
Message-ID: <20071012012125.271326205@linux-foundation.org>
References: <20071012011951.575936605@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46559 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753620AbXJLBWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 21:22:24 -0400
Content-Disposition: inline; filename=fiber-mode-reorder.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put initialization in sequential order (same as other constants).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-10-11 18:13:00.000000000 -0700
+++ b/drivers/net/sky2.c	2007-10-11 18:13:01.000000000 -0700
@@ -296,10 +296,10 @@ static const u16 copper_fc_adv[] = {
 
 /* flow control to advertise bits when using 1000BaseX */
 static const u16 fiber_fc_adv[] = {
-	[FC_BOTH] = PHY_M_P_BOTH_MD_X,
+	[FC_NONE] = PHY_M_P_NO_PAUSE_X,
 	[FC_TX]   = PHY_M_P_ASYM_MD_X,
 	[FC_RX]	  = PHY_M_P_SYM_MD_X,
-	[FC_NONE] = PHY_M_P_NO_PAUSE_X,
+	[FC_BOTH] = PHY_M_P_BOTH_MD_X,
 };
 
 /* flow control to GMA disable bits */

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

