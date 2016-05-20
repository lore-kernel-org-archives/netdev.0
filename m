From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v2 0/7] Driver: Vmxnet3: Version 3
Date: Thu, 19 May 2016 23:53:05 -0700
Message-ID: <1463727192-4543-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset upgrades Vmxnet3 to Version 3.

Changes in v2:
 - Following patch is updated. See that patch for details:
   Driver: Vmxnet3: Add support for get_coalesce, set_coalesce ethtool

Shrikrishna Khare (7):
  Driver: Vmxnet3: Prepare for version 3 changes
  Driver: Vmxnet3: Introduce generic command interface to configure the
    device
  Driver: Vmxnet3: Allow variable length Transmit Data ring buffer
  Driver: Vmxnet3: Add Receive Data Ring support
  Driver: Vmxnet3: Add support for get_coalesce, set_coalesce ethtool
    operations
  Driver: Vmxnet3: Introduce command to register memory region
  Driver: Vmxnet3: Update to Version 3

 drivers/net/vmxnet3/Makefile          |   4 +-
 drivers/net/vmxnet3/upt1_defs.h       |   4 +-
 drivers/net/vmxnet3/vmxnet3_defs.h    | 105 ++++++++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 286 ++++++++++++++++++++++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 217 ++++++++++++++++++++++++--
 drivers/net/vmxnet3/vmxnet3_int.h     |  54 ++++++-
 6 files changed, 588 insertions(+), 82 deletions(-)

-- 
2.8.2
