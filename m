From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: Implement Multi Tx queues and ndo_get_phys_port support for 82xx.
Date: Wed, 21 Aug 2013 11:24:09 -0400
Message-ID: <cover.1377122994.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:8016 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069Ab3HUPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 11:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This patch series contains following updates

 o Patches for enabling multiple Tx queues for 82xx series adapter

 o Patch to implement ndo_get_phys_port support for 82xx series adapter.

Please apply to net-next.

Thanks,
Himanshu

Himanshu Madhani (4):
  qlcnic: Multi Tx queue support for 82xx Series adapter.
  qlcnic: Enable Tx queue changes using ethtool for 82xx Series adapter.
  qlcnic: Enable diagnostic test for multiple Tx queues.
  qlcnic: Update version to 5.3.48

Shahed Shaikh (1):
  qlcnic: Implement ndo_get_phys_port_id for 82xx adapter

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 107 +++++++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  12 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 206 +++++++++++----
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |  65 ++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  18 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   8 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |  12 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 145 +++++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 284 ++++++++++++++++++---
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |   2 +-
 12 files changed, 711 insertions(+), 154 deletions(-)

-- 
1.8.1.4
