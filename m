From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 29/33] sfc: Use model numbers for PHY type names
Date: Fri, 12 Dec 2008 12:59:44 +0000
Message-ID: <20081212125944.GC10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:41234 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758038AbYLLM7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:59:47 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the PHY type names are overly generic.  Change them to include
the model numbers of the PHYs they represent.

Correct the model number reference at the top of xfp_phy.c.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |    2 +-
 drivers/net/sfc/net_driver.h |    6 +++---
 drivers/net/sfc/xfp_phy.c    |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8107460..63414ce 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2263,7 +2263,7 @@ static int falcon_probe_phy(struct efx_nic *efx)
 	case PHY_TYPE_SFT9001B:
 		efx->phy_op = &falcon_sft9001_phy_ops;
 		break;
-	case PHY_TYPE_XFP:
+	case PHY_TYPE_QT2022C2:
 		efx->phy_op = &falcon_xfp_phy_ops;
 		break;
 	default:
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 1728329..7033dba 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -453,10 +453,10 @@ enum efx_int_mode {
 
 enum phy_type {
 	PHY_TYPE_NONE = 0,
-	PHY_TYPE_CX4_RTMR = 1,
-	PHY_TYPE_1G_ALASKA = 2,
+	PHY_TYPE_TXC43128 = 1,
+	PHY_TYPE_88E1111 = 2,
 	PHY_TYPE_SFX7101 = 3,
-	PHY_TYPE_XFP = 4,
+	PHY_TYPE_QT2022C2 = 4,
 	PHY_TYPE_PM8358 = 6,
 	PHY_TYPE_SFT9001A = 8,
 	PHY_TYPE_SFT9001B = 10,
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 345ffc3..2d50b6e 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -7,7 +7,7 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 /*
- * Driver for XFP optical PHYs (plus some support specific to the Quake 2032)
+ * Driver for XFP optical PHYs (plus some support specific to the Quake 2022/32)
  * See www.amcc.com for details (search for qt2032)
  */
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
