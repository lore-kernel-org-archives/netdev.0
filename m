From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: Enable support for 84xx Series adapter
Date: Fri, 16 Aug 2013 19:07:12 -0400
Message-ID: <cover.1376720973.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51217 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753380Ab3HQAAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This patch series enables support for 84xx series adapters.

Please apply to net-next

Thanks,
Himanshu

Himanshu Madhani (1):
  qlcnic: Update version to 5.3.47

Manish Chopra (3):
  qlcnic: Enable support for 844X adapter
  qlcnic: Add PVID support for 84xx adapters
  qlcnic: Loopback Inter Driver Communication AEN handler

Pratik Pujar (1):
  qlcnic: Add support for 84xx adapters to load firmware from file

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 21 +++++++---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 45 +++++++++++++++++-----
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  3 ++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  | 28 +++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  5 +--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 11 ++++++
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   | 20 ++++++----
 7 files changed, 105 insertions(+), 28 deletions(-)

-- 
1.8.1.4
