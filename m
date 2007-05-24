From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/7] sky2: enable IRQ on duplex renegotiation
Date: Thu, 24 May 2007 15:22:47 -0700
Message-ID: <20070524222538.725354382@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:48228 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756036AbXEXWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:30:30 -0400
Content-Disposition: inline; filename=sky2-duplex-irq.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't want IRQ on FIFO error because there is nothing useful to do with it.
But do want IRQ on duplex change.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.h	2007-05-22 10:42:36.000000000 -0700
+++ b/drivers/net/sky2.h	2007-05-22 10:44:35.000000000 -0700
@@ -1149,7 +1149,7 @@ enum {
 	PHY_M_IS_JABBER		= 1<<0, /* Jabber */
 
 	PHY_M_DEF_MSK		= PHY_M_IS_LSP_CHANGE | PHY_M_IS_LST_CHANGE
-				 | PHY_M_IS_FIFO_ERROR,
+				 | PHY_M_IS_DUP_CHANGE,
 	PHY_M_AN_MSK	       = PHY_M_IS_AN_ERROR | PHY_M_IS_AN_COMPL,
 };
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

