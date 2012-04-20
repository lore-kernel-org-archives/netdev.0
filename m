From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 0/9] atl1c: update hardware settings - v3
Date: Fri, 20 Apr 2012 14:16:15 +0800
Message-ID: <1334902584-15584-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:60151 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab2DTGQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 02:16:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This update contains a serial of patches, most of them are hardware
settings related. register definitions are refined (or removed if
meaningless) for each patch.

This is the third serial patches, after reviewed/applied the fourth
serial will be out.

The patches have addressed all sparse and checkpatch warnings.

Following NICs are tested:
AR8131/AR8132/AR8151A/AR8152A/AR8152B
Test item includes:
build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.

xiong (9):
  atl1c: remove REG_PHY_STATUS
  atl1c: refine phy-register read/write function
  atl1c: remove PHY contrl in atl1c_reset_pcie
  atl1c: refine SERDES-clock related code
  atl1c: remove PHY polling from atl1c_open
  atl1c: update PHY reset related routine
  atl1c: remove PHY reset/init for link down event
  atl1c: add function atl1c_power_saving
  atl1c: refine start/enable code for MAC module

 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c      |  422 ++++++++++++-----
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h      |  499 +++++++++++++-------
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |  240 +++-------
 4 files changed, 693 insertions(+), 470 deletions(-)

-- 
1.7.7
