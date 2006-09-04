From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make drivers/net/e1000/e1000_hw.c:e1000_phy_igp_get_info() static
Date: Mon, 4 Sep 2006 13:41:14 +0200
Message-ID: <20060904114114.GL4416@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:23306 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S964800AbWIDLlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 07:41:18 -0400
To: cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	auke-jan.h.kok@intel.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the needlessly global e1000_phy_igp_get_info() static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.18-rc5-mm1/drivers/net/e1000/e1000_hw.c.old	2006-09-01 21:00:00.000000000 +0200
+++ linux-2.6.18-rc5-mm1/drivers/net/e1000/e1000_hw.c	2006-09-01 21:00:19.000000000 +0200
@@ -4056,7 +4056,7 @@
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-int32_t
+static int32_t
 e1000_phy_igp_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {


-- 
VGER BF report: U 0.468609
