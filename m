From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v2 0/5] qlcnic: Mailbox refactoring
Date: Wed, 31 Jul 2013 17:10:57 -0400
Message-ID: <cover.1375314056.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44165 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835Ab3GaV6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 17:58:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This  series contains 
* patch for returning correct error code for loopback diagnostic test.
* patches for mailbox refactoring. 

changes from v1 -> v2
* dropped "qlcnic: Add ethtool statistics for board temperature."

Please consider applying to net-next.

Thanks,
Himanshu

Himanshu Madhani (1):
  qlcnic: Update version to 5.2.45

Jitendra Kalsaria (1):
  qlcnic: Return appropriate error code.

Manish Chopra (3):
  qlcnic: Interrupt based driver firmware mailbox mechanism
  qlcnic: Replace poll mode mailbox interface with interrupt based
    mailbox interface
  qlcnic: Enable mailbox interface in poll mode when interrupts are not
    available

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  56 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 615 +++++++++++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  27 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  83 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  18 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   | 146 ++---
 7 files changed, 648 insertions(+), 299 deletions(-)

-- 
1.8.1.4
