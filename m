From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 0/6] qlcnic: Mailbox refactoring and ethtool updates
Date: Tue, 30 Jul 2013 21:54:18 -0400
Message-ID: <cover.1375244889.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35171 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918Ab3GaCWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 22:22:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

This series contains
* patch for adding board temperature for ethtool statistics.
* patch for returning correct error code for loopback diagnostic test.
* patches for mailbox refactoring. 

There was suggestion from Ben Hutchings, in response to RFC patch, to use
hwmon device for extracting board temperature from an adapter. We are still
investigating this approach. We will send out patches later as a separate 
series when we have decide to implement hwmon API.

Thanks,
Himanshu


Himanshu Madhani (2):
  qlcnic: Add ethtool statistics for board temperature.
  qlcnic: Update version to 5.2.45

Jitendra Kalsaria (1):
  qlcnic: Return appropriate error code.

Manish Chopra (3):
  qlcnic: Interrupt based driver firmware mailbox mechanism
  qlcnic: Replace poll mode mailbox interface with interrupt based
    mailbox interface
  qlcnic: Enable mailbox interface in poll mode when interrupts are not
    available

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  57 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 615 +++++++++++++++------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |  27 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  83 ++-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   7 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  20 +-
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   | 146 ++---
 7 files changed, 656 insertions(+), 299 deletions(-)

-- 
1.8.1.4
