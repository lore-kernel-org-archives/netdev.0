From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 0/2] amd-xgbe: AMD XGBE driver fixes 2017-01-20
Date: Fri, 20 Jan 2017 12:13:52 -0600
Message-ID: <20170120181352.2321.63733.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0089.outbound.protection.outlook.com ([104.47.41.89]:11424
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752219AbdATSN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 13:13:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses some issues in the AMD XGBE driver.

The following fixes are included in this driver update series:

- Add a fix for a version of the hardware that uses different register
  offset values for a device with the same PCI device ID
- Add support to check the return code from the xgbe_init() function

This patch series is based on net.

---

Tom Lendacky (2):
      amd-xgbe: Add a hardware quirk for register definitions
      amd-xgbe: Check xgbe_init() return code


 drivers/net/ethernet/amd/xgbe/xgbe-common.h |    2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    8 +++++---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |    4 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c    |   15 ++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    2 ++
 5 files changed, 26 insertions(+), 5 deletions(-)

-- 
Tom Lendacky
