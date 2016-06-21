From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 0/2] qed*: coalesce parameters config support.
Date: Tue, 21 Jun 2016 09:36:20 -0400
Message-ID: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:28355 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751579AbcFUPII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series adds the support for config/read of the adapter coalesce
parameters. Patch (1) adds the qed infrastructure/APIs for the support and
patch (2) adds the driver support for following ethtool commands:
	ethtool -c|--show-coalesce ethX
	ethtool -C|--coalesce ethX [rx-usecs N] [tx-usecs N]

Sudarsana Reddy Kalluru (2):
  qed: Add support for coalescing config read/update.
  qede: Add support for coalescing config read/update.

 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 104 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h   |  47 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_hw.c        |  23 ++++++
 drivers/net/ethernet/qlogic/qed/qed_int.c       |  75 +++++++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_int.h       |   3 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  34 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |   2 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  53 ++++++++++++
 include/linux/qed/qed_if.h                      |  24 ++++++
 9 files changed, 360 insertions(+), 5 deletions(-)

-- 
1.8.3.1
