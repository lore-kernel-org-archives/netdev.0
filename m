From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/11][pull request] Intel Wired LAN Driver Update
Date: Thu, 23 Jun 2011 23:03:06 -0700
Message-ID: <1308895397-23133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21960 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab1FXGDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 02:03:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe.  There are 2 fixes, along
with several cleanups from Alex and Emil.  In addition, nfc support was added
as well as bumping the driver version.

Dropped patch 7 (ixgbe: add support for modifying UDP RSS flow hash options)
from the previous submission based on comments from Ben H.

The following are changes since commit 4d054f2f1445aceedab3f9642692d55d2caa7ec6:
  dcb: use nlmsg_free() instead of kfree()
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (7):
  ixgbe: remove ntuple filtering
  ixgbe: fix flags relating to perfect filters to support coexistence
  ixgbe: update perfect filter framework to support retaining filters
  ixgbe: add basic support for setting and getting nfc controls
  ixgbe: add support for displaying ntuple filters via the nfc
    interface
  ixgbe: add support for nfc addition and removal of filters
  ixgbe: fix ring assignment issues for SR-IOV and drop cases

Don Skidmore (1):
  ixgbe: update driver version string

Emil Tantilov (3):
  ixgbe: move setting RSC into a separate function
  ixgbe: move reset code into a separate function
  ixgbe: disable RSC when Rx checksum is off

 drivers/net/ixgbe/ixgbe.h         |   29 ++-
 drivers/net/ixgbe/ixgbe_82599.c   |  603 +++++++++++++++++++++----------------
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   13 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |  544 ++++++++++++++++++++++++---------
 drivers/net/ixgbe/ixgbe_main.c    |   89 ++++--
 drivers/net/ixgbe/ixgbe_type.h    |   28 +-
 6 files changed, 850 insertions(+), 456 deletions(-)

-- 
1.7.5.4

