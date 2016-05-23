From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 0/4] qed/qede support for dcbnl.
Date: Mon, 23 May 2016 05:17:39 -0400
Message-ID: <1463995063-25560-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:51731 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751894AbcEWKAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 06:00:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series adds the dcbnl functionality to the driver. Patch (1) fixes a
coding issue in earlier submission. Patch (2) adds the qed infrastucture
for querying/configuring the dcbx parameters. Patch (3) adds the qed
infrastructure for dcbnl APIs. And patch (4) adds the qede support for
dcbnl.

Please consider applying this series to "net-next".

Thanks,
Sudarsana

Sudarsana Reddy Kalluru (4):
  qed: Reset the enable flag for eth protocol.
  qed: Add support for query/config dcbx.
  qed: Add dcbnl support.
  qede: Add dcbnl support.

 drivers/net/ethernet/qlogic/qed/qed_dcbx.c    | 1626 ++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_dcbx.h    |   21 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c      |    7 +
 drivers/net/ethernet/qlogic/qede/Makefile     |    1 +
 drivers/net/ethernet/qlogic/qede/qede.h       |    3 +
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c |  348 ++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c  |    4 +
 include/linux/qed/qed_eth_if.h                |   62 +
 include/linux/qed/qed_if.h                    |   90 ++
 9 files changed, 2160 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c

-- 
1.8.3.1
