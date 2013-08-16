From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH v3 0/3] enic: This patchset adds support for Cisco Low Latency NIC
Date: Fri, 16 Aug 2013 15:47:38 -0700
Message-ID: <1376693261-1949-1-git-send-email-neepatel@cisco.com>
Cc: umalhi@cisco.com, Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>,
	Christian Benvenuti <benve@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:40544 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627Ab3HPWro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:47:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:  
    - Removed OOM messages 
    - Removed ethtool patch where, enic was storing ASIC info in a reserved 
        field of ethtool_drvinfo structure 
 
v2 -> v3: 
    - Removed unused functions for descriptor prefetch, because, this feature is  
        not enabled yet.

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
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h | 176 +++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_rq.c     |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.h     |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.c     |   3 -
 drivers/net/ethernet/cisco/enic/vnic_wq.h     |  14 +-
 11 files changed, 282 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.c
 create mode 100644 drivers/net/ethernet/cisco/enic/enic_api.h

-- 
1.8.4-rc0
