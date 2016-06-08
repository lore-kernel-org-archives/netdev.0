From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH resend net-next 0/3] qed/qede support for dcbnl.
Date: Wed, 8 Jun 2016 06:22:09 -0400
Message-ID: <1465381332-10064-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46281 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753209AbcFHLGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 07:06:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds the dcbnl functionality to the driver. Patch (1) adds
the qed infrastucture for querying/configuring the dcbx parameters.
Patch (2) adds the qed infrastructure for dcbnl APIs. And patch (3)
adds the qede support for dcbnl.

Sudarsana Reddy Kalluru (3):
  qed: Add support for query/config dcbx.
  qed: Add dcbnl support.
  qede: Add dcbnl support.

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c    | 1623 ++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h    |   28 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h     |    3 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c      |    7 +
 drivers/net/ethernet/qlogic/qede/Makefile     |    1 +
 drivers/net/ethernet/qlogic/qede/qede.h       |    3 +
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c |  348 ++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c  |    4 +
 include/linux/qed/qed_eth_if.h                |   62 +
 include/linux/qed/qed_if.h                    |   90 ++
 10 files changed, 2168 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c

-- 
1.8.3.1
