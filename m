From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/8] amd-xgbe: AMD XGBE driver updates 2015-09-30
Date: Wed, 30 Sep 2015 08:52:32 -0500
Message-ID: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0070.outbound.protection.outlook.com ([157.56.111.70]:64640
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751539AbbI3OIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:08:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are included in this driver update series:

- Remove unneeded semi-colon
- Follow the DT/ACPI precedence used by the device_ APIs
- Add ethtool support for getting and setting the msglevel
- Add ethtool support error and debug messages
- Simplify the hardware FIFO assignment calculations
- Add receive buffer unavailable statistic
- Use the device workqueue instead of the system workqueue
- Remove the use of a link state bit

This patch series is based on net-next.

---

Tom Lendacky (8):
      amd-xgbe: Remove an unneeded semicolon on a switch statement
      amd-xgbe: Use proper DT / ACPI precedence checking
      amd-xgbe: Add ethtool support for setting the msglevel
      amd-xgbe: Add ethtool error and debug messages
      amd-xgbe: Simplify calculation and setting of queue fifos
      amd-xgbe: Add receive buffer unavailable statistic
      amd-xgbe: Use device workqueue instead of system workqueue
      amd-xgbe: Remove the XGBE_LINK state bit


 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   83 ++++----------------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   14 ++-
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |  106 +++++++++++++-------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |   16 +---
 drivers/net/ethernet/amd/xgbe/xgbe.h         |   18 ----
 6 files changed, 84 insertions(+), 155 deletions(-)

-- 
Tom Lendacky
