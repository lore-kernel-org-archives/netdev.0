From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/13][pull request] Intel Wired LAN Driver Update
Date: Sat, 14 May 2011 18:23:34 -0700
Message-ID: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52581 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970Ab1EOBXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, ixgbevf and ixgbe.

-e1000e: minor comment fix
-ixgbevf: add support for macvlan
-ixgbe: mostly cleanup with the addition of support for a new adapter

The following are changes since commit 7be799a70ba3dd90a59e8d2c72bbe06020005b3f:
  ipv4: Remove rt->rt_dst reference from ip_forward_options()
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (7):
  ixgbe: move flags and state into the same cacheline
  ixgbe: Combine SFP and multi-speed fiber task into single service
    task
  ixgbe: Merge watchdog functionality into service task
  ixgbe: merge reset task into service task
  ixgbe: Merge ATR reinit into the service task
  ixgbe: Merge over-temp task into service task
  ixgbe: cleanup some minor issues in ixgbe_down()

Bruce Allan (1):
  e1000e: minor comment cleanups

Don Skidmore (1):
  ixgbe: Add support for new 82599 adapter

Emil Tantilov (2):
  ixgbe: force unlock on timeout
  ixgbe: fix sparse warning

Greg Rose (2):
  ixgbevf: Add macvlan support in the set rx mode op
  ixgbe: Add macvlan support for VF

 drivers/net/e1000e/lib.c           |    4 +-
 drivers/net/ixgbe/ixgbe.h          |  110 +++--
 drivers/net/ixgbe/ixgbe_82599.c    |    3 +
 drivers/net/ixgbe/ixgbe_common.c   |   22 +
 drivers/net/ixgbe/ixgbe_ethtool.c  |    1 +
 drivers/net/ixgbe/ixgbe_main.c     |  972 ++++++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_mbx.h      |    1 +
 drivers/net/ixgbe/ixgbe_sriov.c    |   98 ++++-
 drivers/net/ixgbe/ixgbe_type.h     |    2 +
 drivers/net/ixgbevf/ixgbevf_main.c |   30 ++
 drivers/net/ixgbevf/mbx.h          |    1 +
 drivers/net/ixgbevf/vf.c           |   34 ++
 drivers/net/ixgbevf/vf.h           |    1 +
 13 files changed, 793 insertions(+), 486 deletions(-)

-- 
1.7.4.4

