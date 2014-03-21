From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 0/3] qlcnic: VXLAN offload support
Date: Fri, 21 Mar 2014 04:41:15 -0400
Message-ID: <1395391278-19653-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:29807 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751488AbaCUJRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 05:17:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Hi David,

This patch series containes following changes -

* TSO over IPv4 and IPv6, Tx checksum offload for VXLAN
* Rx checksum offload for VXLAN and support for .ndo_{add|del}_vxlan_port
  netdev ops.

Please apply this series to net-next.

Thanks,
Shahed

Shahed Shaikh (3):
  qlcnic: Add VXLAN Tx offload support
  qlcnic: Add VXLAN Rx offload support
  qlcnic: Update version to 5.3.57

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  45 +++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   3 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   3 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  87 ++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   6 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 179 ++++++++++++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  48 ++++++
 8 files changed, 339 insertions(+), 33 deletions(-)

-- 
1.8.3.1
