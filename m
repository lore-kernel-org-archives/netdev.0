From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/4] i40e: Neatening and object size reductions
Date: Fri, 30 Aug 2013 16:06:06 -0700
Message-ID: <cover.1377903831.git.joe@perches.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just some potential cleanings...

Joe Perches (4):
  i40e: Whitespace cleaning
  i40e: Add and use pf_<level>
  i40e: pf_<level> remove "%s: " ... __func__
  i40e: Convert pf_<level> macros to functions

 drivers/net/ethernet/intel/i40e/i40e.h             |  149 +--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   20 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 1133 ++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   47 +-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |   24 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  652 +++++------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_sysfs.c       |   24 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |    9 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   15 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  217 ++--
 11 files changed, 928 insertions(+), 1366 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty
