From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 32/42] drivers/net/bnx2x: Adjust confusing if indentation
Date: Thu, 5 Aug 2010 22:26:38 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052226210.31692@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58022 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934280Ab0HEU0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:26:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Outdent the code following the if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This patch doesn't change the semantics of the code.  But it might not be
what is intended.

 drivers/net/bnx2x/bnx2x_link.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 0383e30..0fa0991 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1254,11 +1254,11 @@ static void bnx2x_set_autoneg(struct link_params *params,
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
-			CL45_WR_OVER_CL22(bp, params->port,
-					      params->phy_addr,
-					      MDIO_REG_BANK_CL73_IEEEB1,
-					      MDIO_CL73_IEEEB1_AN_ADV2,
-				      reg_val);
+		CL45_WR_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_CL73_IEEEB1,
+				      MDIO_CL73_IEEEB1_AN_ADV2,
+			      reg_val);
 
 		/* CL73 Autoneg Enabled */
 		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
