From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: DCB support
Date: Fri, 23 Aug 2013 13:38:24 -0400
Message-ID: <1377279509-18869-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:23505 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754565Ab3HWSHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:07:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series will enable Data Center Bridging (DCB) feature in
qlcnic driver. Currently the support is limited to CEE version of DCBX.
Only GET operations are supported through CEE rtnetlink interface.

Please apply to net-next.

Thanks,
Sucheta.

Sucheta Chakraborty (5):
  qlcnic: dcb: Query adapter DCB capabilities.
  qlcnic: dcb: Get DCB parameters from the adapter.
  qlcnic: dcb: Register DCB AEN handler.
  qlcnic: dcb: Add support for CEE Netlink interface.
  qlcnic: Update version to 5.3.49.

 drivers/net/ethernet/qlogic/Kconfig                |   11 +
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  103 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |    5 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    5 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    2 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c    | 1179 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h    |   41 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   24 +
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    6 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |    4 +
 13 files changed, 1386 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
