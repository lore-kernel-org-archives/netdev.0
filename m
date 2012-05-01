From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 00/10] atl1c: update hardware settings - v4
Date: Tue, 1 May 2012 09:38:48 +0800
Message-ID: <1335836338-9425-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This update contains a serial of patches, most of them are hardware
settings related. register definitions are refined (or removed if
meaningless) for each patch.

This is the last patch set.

The patches have addressed all sparse and checkpatch warnings.

Following NICs are tested:
AR8131/AR8132/AR8151A/AR8152A/AR8152B
Test item includes:
build/install/uninstall/dhcp/ping/iperf/wol/reboot/etc.

xiong (10):
  atl1c: add workaround for issue of bit INTX-disable for MSI interrupt
  atl1c: add PHY link event(up/down) patch
  atl1c: clear WoL status when reset pcie
  atl1c: remove code of closing register writable attribution
  atl1c: refine mac address related code
  atl1c: enlarge L1 response waiting timer
  atl1c: cancel task when interface closed
  atl1c: do MAC-reset when PHY link down
  atl1c: Disable L0S when no cable link
  atl1c: remove PHY polling from atl1c_change_mtu

 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    1 +
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c   |  141 ++++++++++++----------
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |   35 ++---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |  151 +++++++++++++++++------
 drivers/pci/quirks.c                            |   12 ++
 5 files changed, 218 insertions(+), 122 deletions(-)

-- 
1.7.7
