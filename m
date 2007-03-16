From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 4/7] skge: ignore unused error interrupts
Date: Fri, 16 Mar 2007 14:01:29 -0700
Message-ID: <20070316210156.026996576@linux-foundation.org>
References: <20070316210125.324052637@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36174 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965939AbXCPVGl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2007 17:06:41 -0400
Content-Disposition: inline; filename=skge-ignore-unused-errors.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following hardware error bits only show up on Genesis chipset
and are handled elsewhere, so they can be masked off.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/skge.h |    1 -
 1 file changed, 1 deletion(-)

--- skge-dev.orig/drivers/net/skge.h
+++ skge-dev/drivers/net/skge.h
@@ -232,7 +232,6 @@ enum {
 	IS_R2_PAR_ERR	= 1<<0,	/* Queue R2 Parity Error */
 
 	IS_ERR_MSK	= IS_IRQ_MST_ERR | IS_IRQ_STAT
-			| IS_NO_STAT_M1 | IS_NO_STAT_M2
 			| IS_RAM_RD_PAR | IS_RAM_WR_PAR
 			| IS_M1_PAR_ERR | IS_M2_PAR_ERR
 			| IS_R1_PAR_ERR | IS_R2_PAR_ERR,

-- 

