From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 0/2] qlcnic: Bug fixes
Date: Fri, 25 Oct 2013 10:38:35 -0400
Message-ID: <1382711917-28501-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12192 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754732Ab3JYPJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 11:09:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

This patch series contains following fixes-
* Performace drop because driver was forcing adapter not to check
  destination IP for LRO.
* driver was not issuing qlcnic_fw_cmd_set_drv_version() to 83xx adapter
  becasue of improper handling of QLCNIC_FW_CAPABILITY_MORE_CAPS bit.

Please apply to net.

Thanks,
Shahed

Shahed Shaikh (2):
  qlcnic: Do not force adapter to perform LRO without destination IP
    check
  qlcnic: Do not read QLCNIC_FW_CAPABILITY_MORE_CAPS bit for 83xx
    adapter

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 6 +++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c      | 7 ++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 6 ++++--
 3 files changed, 9 insertions(+), 10 deletions(-)

-- 
1.8.1.4
