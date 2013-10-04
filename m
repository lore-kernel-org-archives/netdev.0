From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 00/10] qlcnic: fixes and ethtool enhancements.
Date: Fri, 4 Oct 2013 14:30:47 -0400
Message-ID: <cover.1380937706.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59968 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751043Ab3JDTBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 15:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This patch series contains

o patch to fix regression introduced by commit
  aa4a1f7df7cbb98797c9f4edfde3c726e2b3841f.
o updates to ethtool for pause settings and enhance
  register dump to display mask and ring indices.
o cleanup in DCB code and remove redundant eSwitch enablement command.
o fixed firmware dump collection logic to skip unknown entries.
o fix to register device if adapter is in FAILED state.

Please apply to net-next.

Thanks,
Himanshu

Himanshu Madhani (2):
  qlcnic: Validate Tx queue only for 82xx adapters.
  qlcnic: update version to 5.3.51

Jitendra Kalsaria (1):
  qlcnic: Update ethtool standard pause settings.

Pratik Pujar (2):
  qlcnic: Enhance ethtool to display ring indices and interrupt mask
  qlcnic: Firmware dump collection when auto recovery is disabled.

Shahed Shaikh (1):
  qlcnic: Skip unknown entry type while collecting firmware dump

Sony Chacko (1):
  qlcnic: Remove redundant eSwitch enable commands

Sucheta Chakraborty (3):
  qlcnic: Print informational messages only once during driver load.
  qlcnic: dcb code cleanup and refactoring.
  qlcnic: Register netdev in FAILED state for 83xx/84xx

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 102 +-----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  72 ++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   5 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  36 ++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |  48 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    | 182 ++++++++++-----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    | 109 ++++++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  69 +++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  90 +++++-----
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  41 +++--
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   9 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   8 +-
 13 files changed, 417 insertions(+), 356 deletions(-)

-- 
1.8.1.4
