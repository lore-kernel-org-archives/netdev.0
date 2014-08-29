From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 0/4] amd-xgbe: AMD XGBE driver fixes 2014-08-29
Date: Fri, 29 Aug 2014 13:16:44 -0500
Message-ID: <20140829181643.3257.28011.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0184.outbound.protection.outlook.com ([207.46.163.184]:9921
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752775AbaH2SQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 14:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes to the driver.

- Tx hardware queue flushing support dependent on hardware version
- Incorrect reported fifo size
- Proper mmd select in XPCS debugfs support
- Proper queue count for configuring Tx flow control

This patch series is based on net.

---

Tom Lendacky (4):
      amd-xgbe: Check for Tx hardware queue flushing support
      amd-xgbe: Reported fifo size from hardware is not correct
      amd-xgbe: Fix the xpcs mmd debugfs support
      amd-xgbe: Use the Tx queue count for Tx flow control support


 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    8 ++++----
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   15 +++++++++++----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    2 ++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    7 ++++---
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    4 ++++
 5 files changed, 25 insertions(+), 11 deletions(-)

-- 
Tom Lendacky
