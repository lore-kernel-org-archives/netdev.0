From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/7] sky2: program proper register for fiber PHY
Date: Thu, 24 May 2007 15:22:45 -0700
Message-ID: <20070524222538.550481686@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:52528 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752233AbXEXWcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:32:03 -0400
Content-Disposition: inline; filename=sky2-fiber-reg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver was reading value from one register, setting bit and then
writing the wrong register.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-05-22 10:43:12.000000000 -0700
+++ b/drivers/net/sky2.c	2007-05-22 10:44:32.000000000 -0700
@@ -364,7 +364,7 @@ static void sky2_phy_init(struct sky2_hw
 			/* for SFP-module set SIGDET polarity to low */
 			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 			ctrl |= PHY_M_FIB_SIGD_POL;
-			gm_phy_write(hw, port, PHY_MARV_CTRL, ctrl);
+			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
 		}
 
 		gm_phy_write(hw, port, PHY_MARV_EXT_ADR, pg);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

