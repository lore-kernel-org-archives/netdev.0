From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 0/2] qed/qede: Add hardware GRO support
Date: Fri, 4 Mar 2016 12:35:04 -0500
Message-ID: <1457112906-4307-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:64093 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751414AbcCDSP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 13:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series enables hardware GRO and add support for handling
HW aggregated TCP packets in driver receive flow by skipping
software GRO handling in stack.

Please consider applying this series to net-next.

Thanks,
Manish

Manish Chopra (2):
  qed/qede: Add infrastructure support for hardware GRO
  qede: Add slowpath/fastpath support and enable hardware GRO

 drivers/net/ethernet/qlogic/qed/qed_hsi.h    |   14 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |   81 ++++--
 drivers/net/ethernet/qlogic/qede/qede.h      |   22 ++
 drivers/net/ethernet/qlogic/qede/qede_main.c |  384 +++++++++++++++++++++++++-
 include/linux/qed/qed_eth_if.h               |   12 +-
 5 files changed, 476 insertions(+), 37 deletions(-)
