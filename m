From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v4 0/8] qlcnic: ethtool enhancements and code cleanup.
Date: Fri, 18 Oct 2013 12:22:27 -0400
Message-ID: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:28179 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756521Ab3JRQxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 12:53:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This patch series contains

o updates to ethtool for pause settings and enhance
  register dump to display mask and ring indices.
o cleanup in DCB code and remove redundant eSwitch enablement command.
o fixed firmware dump collection logic to skip unknown entries.

Changes from v3 -> v4
o Dropped patch for Tx queue validation to be submitted in net.

Changes from v2 -> v3

o Updated patch to print informational messages as per Joe Perches's comment.

Changes from v1 -> v2

o Dropped patch to register device if adapter is in FAILED state for more rework.
o Updated patch to display ring indices via ethtool per Ben Hutchings's comment.
o Update patch for DCB cleanup per Stephen Hemminger's comment.

Please apply to net-next.

Thanks,
Himanshu

Himanshu Madhani (1):
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

Sucheta Chakraborty (2):
  qlcnic: Print informational messages only once during driver load.
  qlcnic: dcb code cleanup and refactoring.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 101 +----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  40 ++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   5 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  20 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |  47 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    | 184 ++++++++++-----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    | 109 ++++++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  54 ++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  45 +++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |  41 +++--
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   9 +-
 12 files changed, 341 insertions(+), 316 deletions(-)

-- 
1.8.1.4
