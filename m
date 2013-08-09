From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH 0/4] enic: This patchset adds support for Cisco Low Latency NIC
Date: Fri,  9 Aug 2013 11:12:17 -0700
Message-ID: <1376071941-17001-1-git-send-email-neepatel@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:6714 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758595Ab3HISMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:12:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>

Neel Patel (4):
  drivers/net: enic: Adding support for Cisco Low Latency NIC
  drivers/net: enic: Add an interface for USNIC to interact with
    firmware
  drivers/net: enic: Make ASIC information available to USNIC
  drivers/net: enic: Generate notification of hardware crash

 drivers/net/ethernet/cisco/enic/Makefile       |   2 +-
 drivers/net/ethernet/cisco/enic/driver_utils.h |  49 +++++++
 drivers/net/ethernet/cisco/enic/enic.h         |   5 +-
 drivers/net/ethernet/cisco/enic/enic_api.c     |  48 +++++++
 drivers/net/ethernet/cisco/enic/enic_api.h     |  30 +++++
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |   4 +
 drivers/net/ethernet/cisco/enic/enic_main.c    |   4 +
 drivers/net/ethernet/cisco/enic/enic_res.h     |   9 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c     |   5 +
 drivers/net/ethernet/cisco/enic/vnic_dev.h     |   1 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h  | 176 ++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_rq.c      |   9 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.h      |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.c      |   7 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.h      |  86 +++++++++++-
 15 files changed, 419 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/driver_utils.h
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.c
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.h

-- 
1.8.4-rc0
