From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/7] sky2: sky2_reset section mismatch
Date: Wed, 12 Jul 2006 15:23:45 -0700
Message-ID: <20060712222646.276899800@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20361 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751469AbWGLWcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:32:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-devinit-reset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since sky2_reset gets call from sky2_resume it shouldn't be tagged
with devinit.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-07-07 13:02:23.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-07 16:31:29.000000000 -0700
@@ -2286,7 +2286,7 @@
 }
 
 
-static int __devinit sky2_reset(struct sky2_hw *hw)
+static int sky2_reset(struct sky2_hw *hw)
 {
 	u16 status;
 	u8 t8, pmd_type;

--

