From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/2][pull request] 10GbE Intel Wired LAN Driver Updates 2016-05-16
Date: Mon, 16 May 2016 19:25:22 -0700
Message-ID: <1463451924-96911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2862 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbcEQCZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2016 22:25:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains 2 fixes to ixgbe only.

Emil fixes transmit hangs when enabling SRIOV by swapping the parameters
in GENMASK in order to generate the correct mask.

Alex fixes his previous patch b83e30104bd9 ("ixgbe/ixgbevf: Add support
for GSO partial") where he somehow transposed the location of setting
the VLAN features in netdev->features and the configuration of the
vlan_features.

The following are changes since commit 7e2c3aea4398d079745b9faa2c17b6cbd010f221:
  net: also make sch_handle_egress() drop monitor ready
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (1):
  ixgbe: Fix VLAN features error

Emil Tantilov (1):
  ixgbe: use correct mask when enabling sriov

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.5.5
