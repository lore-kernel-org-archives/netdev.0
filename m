From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 0/4] amd-xgbe: AMD XGBE driver updates 2014-09-03
Date: Wed, 3 Sep 2014 12:14:10 -0500
Message-ID: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:61921
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932711AbaICR3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:29:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series of patches includes fixes/updates to the driver.

- Query the device for the actual speed mode (KR/KX) rather than trying
  to track it
- Update parallel detection logic to support KR mode
- Fix new warnings from checkpatch in the amd-xgbe and amd-xgbe-phy
  driver

This patch series is based on net-next.

---

Tom Lendacky (4):
      amd-xgbe-phy: Check device for current speed mode (KR/KX)
      amd-xgbe-phy: Enhance parallel detection to support KR speed
      amd-xgbe: Checkpatch driver fixes
      amd-xgbe-phy: Checkpatch driver fixes


 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |   11 --
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c     |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c    |    6 -
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    2 
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c     |    1 
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    2 
 drivers/net/phy/amd-xgbe-phy.c               |  169 +++++++++++++++-----------
 12 files changed, 102 insertions(+), 95 deletions(-)

-- 
Tom Lendacky
