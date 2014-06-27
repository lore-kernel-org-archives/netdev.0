From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next 0/2] qlcnic: Enhance Tx timeout debug data collection.
Date: Fri, 27 Jun 2014 19:01:37 -0400
Message-ID: <1403910099-2835-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46129 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbaF0XcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 19:32:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

The following set of patches are for enhancing Tx timeout debug collection

- Collect a firmware dump on first Tx timeout if netif_msg_tx_err() is set
- Log Receive and Status ring info on Tx timeout, in addition to Tx ring info
- Log additional Tx ring info if netif_msg_tx_err() is set
- Update driver version to 5.3.61

Please apply this series to net-next.

Thanks,
Harish

Harish Patil (2):
   qlcnic: Enhance Tx timeout debug data collection.
   qlcnic: Update version to 5.3.61

drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |  4 ++--
drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 41
+++++++++++++++++++++++++++++++++++------
2 files changed, 37 insertions(+), 8 deletions(-)
