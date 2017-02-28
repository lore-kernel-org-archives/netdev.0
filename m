From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 0/3] amd-xgbe: AMD XGBE driver fixes 2017-02-28
Date: Tue, 28 Feb 2017 15:02:42 -0600
Message-ID: <20170228210242.32166.30038.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0064.outbound.protection.outlook.com ([104.47.38.64]:2048
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751646AbdB1VlO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 16:41:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series addresses some issues in the AMD XGBE driver.

The following fixes are included in this driver update series:

- Stop the PHY before disabling and releasing device interrupts so that
  MDIO requests issued by the device can be properly handled
- Set the MDIO communication mode on device startup, not just device
  probe
- Do not overwrite SFP settings when mod_absent is detected

This patch series is based on net.

---

Tom Lendacky (3):
      amd-xgbe: Stop the PHY before releasing interrupts
      amd-xgbe: Be sure to set MDIO modes on device (re)start
      amd-xgbe: Don't overwrite SFP PHY mod_absent settings


 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |    4 ++--
 drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c |   24 ++++++++++++++++++++++++
 3 files changed, 27 insertions(+), 3 deletions(-)

-- 
Tom Lendacky
