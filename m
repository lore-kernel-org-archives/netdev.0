From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 00/14] be2net updates
Date: Sat, 20 Oct 2012 21:31:05 +0530
Message-ID: <158bb887-7f4c-4d3d-abc3-c5cb50c06edb@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:39990 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab2JTQCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:02:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (14):
  be2net: Fix driver load failure for different FW configs in Lancer
  be2net: Fix setting QoS for VF for Lancer
  be2net: Fix change MAC operation for VF for Lancer
  be2net: Wait till resources are available for VF in error recovery
  be2net: Fix configuring VLAN for VF for Lancer
  be2net: Fix error messages while driver load for VFs
  be2net: Fix ethtool get_settings output for VF
  be2net: Fix issues in error recovery due to wrong queue state
  be2net: Fix unnecessary delay in PCI EEH
  be2net: Fix VF driver load on newer Lancer FW
  be2net: Enabling Wake-on-LAN is not supported in S5 state
  be2net: Fix FW flashing on Skyhawk-R
  be2net: Fix skyhawk VF PCI Device ID
  be2net: Update driver version

 drivers/net/ethernet/emulex/benet/be.h         |   20 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  385 +++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  138 ++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   80 +++--
 drivers/net/ethernet/emulex/benet/be_hw.h      |    3 +
 drivers/net/ethernet/emulex/benet/be_main.c    |  533 +++++++++++++++++-------
 6 files changed, 971 insertions(+), 188 deletions(-)
