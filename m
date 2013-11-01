From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 0/6] qlcnic: Multiple Tx queue support and code refactoring
Date: Fri, 1 Nov 2013 16:51:23 -0400
Message-ID: <cover.1383358893.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10631 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753169Ab3KAVWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 17:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This Patch series contains following changes

o Refactored code for Tx/SDS ring calculation, validation for various modes.
o Enhanced ethtool statistics for multi Tx queue on all supported adapters.
o Enable multiple Tx queue for 83xx and 84xx Series adapters.
o Regiser netdev for failed device state.
o Replaced inapropriate usage of kzalloc() with vzalloc().

Please apply to net-next.

Thanks,
Himanshu


Himanshu Madhani (4):
  qlcnic: Enhance ethtool Statistics for Multiple Tx queue.
  qlcnic: refactor Tx/SDS ring calculation and validation in driver.
  qlcnic: Enable multiple Tx queue support for 83xx/84xx Series
    adapters.
  qlcnic: update version to 5.3.52

Manish Chopra (1):
  qlcnic: Replace kzalloc() with vzalloc().

Sucheta Chakraborty (1):
  qlcnic: Register netdev in FAILED state for 83xx/84xx

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  84 +++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 109 +++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  13 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  70 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |  26 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    |  12 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 216 +++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   8 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  65 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 410 +++++++++++----------
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   6 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |  12 +-
 13 files changed, 596 insertions(+), 437 deletions(-)

-- 
1.8.1.4
