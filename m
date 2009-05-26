From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/4] igb/e1000e: update PSSR_MDIX value to
	reflect correct bit
Date: Tue, 26 May 2009 16:51:05 -0700
Message-ID: <20090526235105.28231.39406.stgit@localhost.localdomain>
References: <20090526234958.28231.16894.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:60111
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760821AbZEZXvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 19:51:22 -0400
In-Reply-To: <20090526234958.28231.16894.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The phy port status register has the MDI-X status bit on bit 11, not bit 3
as is currently setup in the define.  This patch corrects that so the
correct bit is checked on igp PHY types.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h     |    2 +-
 drivers/net/igb/e1000_phy.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index d8b8229..6cdb703 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -253,7 +253,7 @@ enum e1e_registers {
 #define IGP01E1000_PLHR_SS_DOWNGRADE	0x8000
 
 #define IGP01E1000_PSSR_POLARITY_REVERSED	0x0002
-#define IGP01E1000_PSSR_MDIX			0x0008
+#define IGP01E1000_PSSR_MDIX			0x0800
 #define IGP01E1000_PSSR_SPEED_MASK		0xC000
 #define IGP01E1000_PSSR_SPEED_1000MBPS		0xC000
 
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/igb/e1000_phy.h
index 3228a86..ebe4b61 100644
--- a/drivers/net/igb/e1000_phy.h
+++ b/drivers/net/igb/e1000_phy.h
@@ -80,7 +80,7 @@ s32  igb_phy_init_script_igp3(struct e1000_hw *hw);
 #define IGP02E1000_PM_D3_LPLU             0x0004 /* For all other states */
 #define IGP01E1000_PLHR_SS_DOWNGRADE      0x8000
 #define IGP01E1000_PSSR_POLARITY_REVERSED 0x0002
-#define IGP01E1000_PSSR_MDIX              0x0008
+#define IGP01E1000_PSSR_MDIX              0x0800
 #define IGP01E1000_PSSR_SPEED_MASK        0xC000
 #define IGP01E1000_PSSR_SPEED_1000MBPS    0xC000
 #define IGP02E1000_PHY_CHANNEL_NUM        4

