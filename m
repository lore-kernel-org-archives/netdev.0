From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/12][pull request] Intel Wired LAN Driver Update
Date: Wed, 22 Jun 2011 18:44:24 -0700
Message-ID: <1308793476-11596-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:33253 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932181Ab1FWBoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 21:44:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to ixgbe.  There are 2 fixes, along
with several cleanups from Alex and Emil.  In addition, nfc support was added
as well as bumping the driver version.

The following are changes since commit 56f8a75c17abb854b5907f4a815dc4c3f186ba11:
  ip: introduce ip_is_fragment helper inline function
and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Alexander Duyck (8):
  ixgbe: remove ntuple filtering
  ixgbe: fix flags relating to perfect filters to support coexistence
  ixgbe: update perfect filter framework to support retaining filters
  ixgbe: add basic support for setting and getting nfc controls
  ixgbe: add support for displaying ntuple filters via the nfc
    interface
  ixgbe: add support for nfc addition and removal of filters
  ixgbe: add support for modifying UDP RSS flow hash options
  ixgbe: fix ring assignment issues for SR-IOV and drop cases

Don Skidmore (1):
  ixgbe: update driver version string

Emil Tantilov (3):
  ixgbe: move setting RSC into a separate function
  ixgbe: move reset code into a separate function
  ixgbe: disable RSC when Rx checksum is off

 drivers/net/ixgbe/ixgbe.h         |   31 ++-
 drivers/net/ixgbe/ixgbe_82599.c   |  603 ++++++++++++++++++--------------
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |   13 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |  696 +++++++++++++++++++++++++++++--------
 drivers/net/ixgbe/ixgbe_main.c    |   94 ++++--
 drivers/net/ixgbe/ixgbe_type.h    |   28 +-
 6 files changed, 1009 insertions(+), 456 deletions(-)

-- 
1.7.5.4

