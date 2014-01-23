From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 0/7] qlcnic: Refactoring and enhancements for all adapters.
Date: Thu, 23 Jan 2014 17:18:27 -0500
Message-ID: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:26448 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755578AbaAWWww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:52:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This patch series contains following patches.

o Enhanced debug data collection when we are in Tx-timeout situation.
o Enhanced MSI-x vector calculation for defualt load path as well
  as for TSS/RSS ring change path.
o Refactored interrupt coalescing code for all adapters.
o Refactored interrupt handling as well as cleanup of poll controller
  code patch for all adapters.
o changed rx_mac_learn type to boolean.

Please apply to net-next.

Thanks,
Himanshu

Himanshu Madhani (4):
  qlcnic: Enhance Tx timeout debugging.
  qlcnic: Refactor interrupt coalescing code for all adapters.
  qlcnic: Enhance logic to calculate msix vectors.
  qlcnic: update version to 5.3.55

Manish chopra (2):
  qlcnic: Interrupt code cleanup
  qlcnic: Update poll controller code path

Sucheta Chakraborty (1):
  qlcnic: Use bool for rx_mac_learn.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 129 ++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 235 ++++++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   9 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |   4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 106 ++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  31 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  55 +---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 343 ++++++++++++++-------
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   2 +
 11 files changed, 601 insertions(+), 321 deletions(-)

-- 
1.8.1.4
