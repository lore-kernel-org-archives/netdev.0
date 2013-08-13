From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH v2 0/3] enic: This patchset adds support for Cisco Low Latency NIC
Date: Tue, 13 Aug 2013 15:19:38 -0700
Message-ID: <1376432381-5546-1-git-send-email-neepatel@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:10515 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758472Ab3HMWTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 18:19:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2: 
	- Removed OOM messages
	- Removed ethtool patch where, enic was storing ASIC info in a reserved
		field of ethtool_drvinfo structure

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>

Neel Patel (3):
  drivers/net: enic: Adding support for Cisco Low Latency NIC
  drivers/net: enic: Add an interface for USNIC to interact with
    firmware
  drivers/net: enic: Generate notification of hardware crash

 drivers/net/ethernet/cisco/enic/Makefile      |   2 +-
 drivers/net/ethernet/cisco/enic/enic.h        |   5 +-
 drivers/net/ethernet/cisco/enic/enic_api.c    |  48 +++++++
 drivers/net/ethernet/cisco/enic/enic_api.h    |  30 +++++
 drivers/net/ethernet/cisco/enic/enic_main.c   |   4 +
 drivers/net/ethernet/cisco/enic/enic_res.h    |   9 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |   5 +
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |   1 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h | 176 +++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_rq.c     |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.h     |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.c     |   3 -
 drivers/net/ethernet/cisco/enic/vnic_wq.h     |  86 ++++++++++++-
 13 files changed, 360 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.c
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.h

-- 
1.8.4-rc0
