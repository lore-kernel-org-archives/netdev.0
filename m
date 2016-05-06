From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next 0/7] Driver: Vmxnet3: Version 3
Date: Fri,  6 May 2016 16:12:09 -0700
Message-ID: <1462576336-83513-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset upgrades Vmxnet3 to Version 3.


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
 drivers/net/vmxnet3/vmxnet3_defs.h    | 106 ++++++++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 278 +++++++++++++++++++++++++++-------
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 192 +++++++++++++++++++++--
 drivers/net/vmxnet3/vmxnet3_int.h     |  50 +++++-
 6 files changed, 551 insertions(+), 83 deletions(-)

-- 
1.9.1
