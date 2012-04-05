From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/3][pull request] Intel Wired LAN Driver Update
Date: Thu,  5 Apr 2012 03:47:55 -0700
Message-ID: <1333622878-3855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55758 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983Ab2DEKsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 06:48:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches contains updates for ixgbe only.

This patch set is a refactor of previous patches that export data
requested by our customers.  The thermals are exposed via hwmon as
suggested by Michal Miroslaw and Ben Hutchings.  Modeled on how Ben
did for the Solarfare driver.  The other values are exported via
sysfs read only files.

The following are changes since commit 51c56b004e2c9a46207bb8a116589c2f84b92e5d:
  net: remove k{un}map_skb_frag()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Don Skidmore (3):
  ixgbe: add support functions to access thermal data
  ixgbe: add hwmon interface to export thermal data
  ixgbe: add syfs interface for to export read only driver information

 drivers/net/ethernet/intel/Kconfig              |    8 +
 drivers/net/ethernet/intel/ixgbe/Makefile       |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |   26 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c  |    2 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c |  169 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.h |   13 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    6 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c  | 1035 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h   |   39 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   |    2 +
 11 files changed, 1303 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c

-- 
1.7.7.6
