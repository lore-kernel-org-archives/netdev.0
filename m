From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 0/8] amd-xgbe: AMD XGBE driver update 2014-07-25
Date: Fri, 25 Jul 2014 16:10:52 -0500
Message-ID: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0211.outbound.protection.outlook.com ([207.46.163.211]:16643
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753971AbaGYVK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 17:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is dependent on the following patch that was
applied to the net tree and needs to be applied to the net-next
tree:
  332cfc823d18 - amd-xgbe: Fix error return code in xgbe_probe()

The following series of patches includes fixes and new support in the
driver.

- Device bindings documentation update
- Hardware timestamp support
- 2.5GbE support changes
- Fifo sizes based on active queues/rings
- Phylib driver updates for:
  - Rate change completion check
  - KR training initiation
  - Auto-negotiation results
- Traffic class support, including DCB support

This patch series is based on net-next.

---

Tom Lendacky (8):
      amd-xgbe: Add dma-coherent to device bindings documentation
      amd-xgbe: Add hardware timestamp support
      amd-xgbe: Update/fix 2.5GbE support
      amd-xgbe: Base queue fifo size and enablement on ring count
      amd-xgbe-phy: Updates to rate change complete check
      amd-xgbe-phy: Updates to KR training initiation
      amd-xgbe-phy: Print out the auto-negotiation method used
      amd-xgbe: Add traffic class support


 .../devicetree/bindings/net/amd-xgbe-phy.txt       |    6 
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   17 +
 drivers/net/ethernet/amd/Kconfig                   |   11 +
 drivers/net/ethernet/amd/xgbe/Makefile             |    4 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        |   93 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c           |  292 ++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |    9 
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |  399 +++++++++++++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  421 ++++++++++++++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   56 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |   36 +-
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c           |  313 +++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   77 ++++
 drivers/net/phy/amd-xgbe-phy.c                     |  134 ++++++
 14 files changed, 1741 insertions(+), 127 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c

-- 
Tom Lendacky
