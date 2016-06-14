From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v4 0/7] vmxnet3: upgrade to version 3
Date: Tue, 14 Jun 2016 11:52:21 -0700
Message-ID: <1465930348-92164-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	pv-drivers@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset upgrades vmxnet3 to version 3.

Changes in v2:
 - Following patch is updated. See that patch for details:
   vmxnet3: add support for get_coalesce, set_coalesce ethtool

Changes in v3:
 - fix subject line to use vmxnet3: instead of Driver:Vmxnet3
 - resubmit when net-next is open

Changes in v4:
 - Following patch is updated. See that patch for details:
   vmxnet3: add support for get_coalesce, set_coalesce ethtool


Shrikrishna Khare (7):
  vmxnet3: prepare for version 3 changes
  vmxnet3: introduce generic command interface to configure the device
  vmxnet3: allow variable length transmit data ring buffer
  vmxnet3: add receive data ring support
  vmxnet3: add support for get_coalesce, set_coalesce ethtool operations
  vmxnet3: introduce command to register memory region
  vmxnet3: update to version 3

 drivers/net/vmxnet3/Makefile          |   4 +-
 drivers/net/vmxnet3/upt1_defs.h       |   4 +-
 drivers/net/vmxnet3/vmxnet3_defs.h    | 105 ++++++++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 285 ++++++++++++++++++++++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 215 +++++++++++++++++++++++--
 drivers/net/vmxnet3/vmxnet3_int.h     |  54 ++++++-
 6 files changed, 585 insertions(+), 82 deletions(-)

-- 
2.8.2
