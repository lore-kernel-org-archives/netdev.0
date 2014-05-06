From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 0/2] Bug fixes.
Date: Tue, 6 May 2014 03:46:47 -0400
Message-ID: <1399362409-17039-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:7997 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934251AbaEFIPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 04:15:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series contain following bug fixes.

* Fix panic where driver was accessing un-initialized crb_intr_mask
  in non Multi-Tx queue mode while dumping TX queue.
* Do not set netdev->real_num_tx_queues directly from driver instead
  use kernel defined netif_set_real_num_tx_queues() API. Also notify
  stack about change in number of Rx queues. 
 
Please apply this series to net.

Thanks,
Rajesh

Manish Chopra (1):
  qlcnic: Fix panic while dumping TX queues on TX timeout

Shahed Shaikh (1):
  qlcnic: Set real_num_{tx|rx}_queues properly

 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |   16 ------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   57 ++++++++++++++++++++--
 2 files changed, 53 insertions(+), 20 deletions(-)
