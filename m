From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 8/9] e1000e: PHY type cleanups in
	e1000e_check_downshift()
Date: Tue, 01 Dec 2009 17:53:48 -0800
Message-ID: <20091202015326.592.83129.stgit@localhost.localdomain>
References: <20091202015250.592.56893.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:48536 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753310AbZLBBx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 20:53:58 -0500
In-Reply-To: <20091202015250.592.56893.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the case for 82577 because it does not support the ability to check
for downshift.  Add case for e1000_phy_bm which can do this.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3e5940a..0c69649 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -1525,8 +1525,8 @@ s32 e1000e_check_downshift(struct e1000_hw *hw)
 	switch (phy->type) {
 	case e1000_phy_m88:
 	case e1000_phy_gg82563:
+	case e1000_phy_bm:
 	case e1000_phy_82578:
-	case e1000_phy_82577:
 		offset	= M88E1000_PHY_SPEC_STATUS;
 		mask	= M88E1000_PSSR_DOWNSHIFT;
 		break;

