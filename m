From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 0/5] qlcnic: Fixes for Mailbox command handling.
Date: Thu, 15 Aug 2013 08:27:24 -0400
Message-ID: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:40578 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756194Ab3HONCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the bug fixes in this series are dependent on net-next patches which were
submitted previously by commit (qlcnic: Interrupt based driver firmware mailbox
mechanism, commit id - e5c4e6c696aea58fbea5758e8b2841d2b0309cf7).

Please apply this series to net-next.

Thanks,
Sucheta.

Manish Chopra (4):
  qlcnic: Reinitialize mailbox data structures after firmware reset
  qlcnic: Flush mailbox command list when mailbox is not available
  qlcnic: Fix driver initialization for 83xx adapters
  qlcnic: Dump mailbox command data when a command times out

Sucheta Chakraborty (1):
  qlcnic: Update version to 5.2.46.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h              |  4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      |  8 +++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    | 14 +++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c |  2 +-
 4 files changed, 17 insertions(+), 11 deletions(-)
