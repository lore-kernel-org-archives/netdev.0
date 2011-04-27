From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/12][pull request] Intel Wired LAN Driver Update
Date: Wed, 27 Apr 2011 02:34:39 -0700
Message-ID: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14485 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368Ab1D0Jez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:34:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e and ixgbe.

- e1000e: convert to new set_phys_id interface

- ixgbe: several cleanups and fixes, as well as the conversion
  to the new set_phys_id interface and driver version bump.

The following are changes since commit 2bd93d7af1581d40e3c4b25242472661cb7c637a:
  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (1):
  ixgbe: remove ntuple display support

Bruce Allan (1):
  e1000e: implement ethtool set_phys_id

Don Skidmore (3):
  ixgbe: enable SCTP checksum offload for X540
  ixgbe: Bump version
  ixgbe: fix X540 ethtool loopback test.

Emil Tantilov (5):
  ixgbe: explicitly disable 100H for x540
  ixgbe: register defines cleanup
  ixgbe: add support for 64k EEPROM for 82599
  ixgbe: add LED blink code for x540
  ixgbe: convert to ethtool set_phys_id

John Fastabend (1):
  ixgbe: fix static functions

Yi Zou (1):
  ixgbe: do not clear FCoE DDP error status for received ABTS

 drivers/net/e1000e/82571.c          |    2 +
 drivers/net/e1000e/e1000.h          |    6 +-
 drivers/net/e1000e/es2lan.c         |    1 +
 drivers/net/e1000e/ethtool.c        |   71 ++++---------
 drivers/net/e1000e/hw.h             |    1 +
 drivers/net/e1000e/ich8lan.c        |    4 +
 drivers/net/e1000e/lib.c            |    4 +-
 drivers/net/e1000e/netdev.c         |    2 -
 drivers/net/ixgbe/ixgbe.h           |    1 +
 drivers/net/ixgbe/ixgbe_82599.c     |   33 ++++++-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c   |   39 +++++---
 drivers/net/ixgbe/ixgbe_fcoe.c      |    4 +-
 drivers/net/ixgbe/ixgbe_main.c      |   19 ++--
 drivers/net/ixgbe/ixgbe_mbx.h       |    3 -
 drivers/net/ixgbe/ixgbe_phy.c       |    3 +-
 drivers/net/ixgbe/ixgbe_sriov.c     |    2 +-
 drivers/net/ixgbe/ixgbe_type.h      |  189 +++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_x540.c      |   64 ++++++++++++-
 19 files changed, 292 insertions(+), 158 deletions(-)

-- 
1.7.4.4

