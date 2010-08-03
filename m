From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000e: correct MAC-PHY interconnect register
	offset for 82579
Date: Tue, 03 Aug 2010 14:48:35 -0700
Message-ID: <20100803214827.5712.8674.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:57004 "EHLO
	qmta04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756424Ab0HCVsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 17:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The MAC-PHY interconnect register set on ICH/PCH parts is accessed through
a peephole mechanism by writing an offset to a CSR register.  The offset
for the interconnect's half-duplex control register (which is used in a
jumbo frame workaround for 82579) is incorrect.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a419b07..66ed08f 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -313,7 +313,7 @@ enum e1e_registers {
 #define E1000_KMRNCTRLSTA_DIAG_NELPBK	0x1000 /* Nearend Loopback mode */
 #define E1000_KMRNCTRLSTA_K1_CONFIG	0x7
 #define E1000_KMRNCTRLSTA_K1_ENABLE	0x0002
-#define E1000_KMRNCTRLSTA_HD_CTRL	0x0002
+#define E1000_KMRNCTRLSTA_HD_CTRL	0x10   /* Kumeran HD Control */
 
 #define IFE_PHY_EXTENDED_STATUS_CONTROL	0x10
 #define IFE_PHY_SPECIAL_CONTROL		0x11 /* 100BaseTx PHY Special Control */

