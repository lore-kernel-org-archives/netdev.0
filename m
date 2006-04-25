From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] sky2: reset function can be devinit
Date: Tue, 25 Apr 2006 10:58:53 -0700
Message-ID: <20060425175952.104222000@localhost.localdomain>
References: <20060425175849.372221000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30081 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932306AbWDYVCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 17:02:37 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-devinit.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2_reset function only called from sky2_probe.
Maybe the compiler was smart enough to figure this out already.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2-2.6.17.orig/drivers/net/sky2.c	2006-04-25 10:53:37.000000000 -0700
+++ sky2-2.6.17/drivers/net/sky2.c	2006-04-25 10:54:57.000000000 -0700
@@ -2219,7 +2219,7 @@
 }
 
 
-static int sky2_reset(struct sky2_hw *hw)
+static int __devinit sky2_reset(struct sky2_hw *hw)
 {
 	u16 status;
 	u8 t8, pmd_type;

--

