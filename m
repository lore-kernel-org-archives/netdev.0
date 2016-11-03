From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 00/10] amd-xgbe: AMD XGBE driver updates
 2016-11-03
Date: Thu, 3 Nov 2016 13:17:28 -0500
Message-ID: <20161103181727.7383.34446.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0072.outbound.protection.outlook.com ([104.47.37.72]:14259
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756796AbcKCSRf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 14:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is targeted at preparing the driver for a new PCI version
of the hardware.  After this series is applied, a follow-on series will
introduce the support for the PCI version of the hardware.

The following updates and fixes are included in this driver update series:

- Fix formatting of PCS debug register dump
- Prepare for priority-based FIFO allocation
- Implement priority-based FIFO allocation
- Prepare for working with more than one type of PCS/PHY
- Prepare for the introduction of clause 37 auto-negotiation
- Add support for clause 37 auto-negotiation
- Prepare for supporting a new PCS register access method
- Add support for 64-bit management counter registers
- Update DMA channel status determination
- Prepare for supporting PCI devices in addition to platform devices

This patch series is based on net-next.

---

Tom Lendacky (10):
      amd-xgbe: Fix formatting of PCS register dump
      amd-xgbe: Prepare for priority-based FIFO allocation
      amd-xgbe: Perform priority-based hardware FIFO allocation
      amd-xgbe: Prepare for working with more than one type of phy
      amd-xgbe: Prepare for introduction of clause 37 autoneg
      amd-xgbe: Add support for clause 37 auto-negotiation
      amd-xgbe: Prepare for a new PCS register access method
      amd-xgbe: Support for 64-bit management counter registers
      amd-xgbe: Update how to determine DMA channel status
      amd-xgbe: Prepare for supporting PCI devices


 drivers/net/ethernet/amd/xgbe/Makefile        |    4 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h   |   71 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      |  847 ++++++++++++++++-----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      |   28 -
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c  |   19 
 drivers/net/ethernet/amd/xgbe/xgbe-main.c     |  662 ++---------------
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c     |  990 ++++++++++++++-----------
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c   |  828 +++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |  632 ++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h          |  213 ++++-
 10 files changed, 2923 insertions(+), 1371 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-phy-v1.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-platform.c

-- 
Tom Lendacky
