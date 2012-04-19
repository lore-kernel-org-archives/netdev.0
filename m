From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 00/11] atl1c: update hardware settings - v2
Date: Thu, 19 Apr 2012 16:01:20 +0800
Message-ID: <1334822491-30129-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:56040 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab2DSIBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 04:01:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This update contains a serial of patches, most of them are hardware
settings related. register definitions are refined (or removed if
meaningless) for each patch.

This is the second serial patches, after reviewed/applied the third
serial will be out.

The patches have addressed all sparse and checkpatch warnings.

Following NICs are tested:
AR8131/AR8132/AR8151A/AR8152A/AR8152B
Test item includes:
build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.


xiong (11):
  atl1c: threshold for ASPM is changed based on chip capability
  atl1c: add module parameter for l1c_wait_until_idle
  atl1c: update right threshold for TSO
  atl1c: remove dmar_dly_cnt and dmaw_dly_cnt
  atl1c: clear PCIE error status in atl1c_reset_pcie
  atl1c: refine reg definition of REG_MASTER_CTRL
  atl1c: clear bit MASTER_CTRL_CLK_SEL_DIS in atl1c_pcie_patch
  atl1c: refine/update ASPM configuration
  atl1c: refine atl1c_pcie_patch
  atl1c: fix WoL(magic) issue for l2cb 1.1
  atl1c: remove MDIO_REG_ADDR_MASK in atl1c_mdio_read/write

 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    4 -
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |  237 ++++++++++++--------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |  282 ++++++++++++-----------
 3 files changed, 290 insertions(+), 233 deletions(-)

-- 
1.7.7
