From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates 2015-04-09
Date: Thu, 9 Apr 2015 12:11:45 -0500
Message-ID: <20150409171145.22188.37025.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0134.outbound.protection.outlook.com ([65.55.169.134]:30810
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755919AbbDIRLu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 13:11:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes functional updates and changes
to the driver.

- Allow ethtool rx-frames coalescing to be changed while the device is up
- Consolidate initialization routine into the init function
- Add support for the TX watchdog timeout

This patch series is based on net-next.

---

Tom Lendacky (3):
      amd-xgbe: Allow rx-frames coalescing to be changed anytime
      amd-xgbe: Move Rx mode configuration into init
      amd-xgbe: Add support for the netdev Tx watchdog


 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   53 ++++++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   23 +++++------
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |   10 -----
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    3 +
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    9 +---
 5 files changed, 53 insertions(+), 45 deletions(-)

-- 
Tom Lendacky
