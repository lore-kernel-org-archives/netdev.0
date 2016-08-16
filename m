From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 0/3] qed*: Add support for additional statistics.
Date: Tue, 16 Aug 2016 10:51:00 -0400
Message-ID: <1471359063-6193-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33885 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753220AbcHPPeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:34:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series adds qed/qede support for new statistics.
Patch (1) adds couple of statistcs for "ethtool -S" display.
Patch (2) adds support for per-queue statistics to ethtool display.
Patch (3) adds qed support for NCSI statistics.

Please consider applying this to 'net-next' branch.

Sudarsana Reddy Kalluru (3):
  qede: Add support for capturing additional stats in ethtool-stats
    display.
  qede: Add support for per-queue stats.
  qed*: Add support for NCSI statistics.

 drivers/net/ethernet/qlogic/qed/qed.h           |  6 ++-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h       | 14 ++++--
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |  2 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 21 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       | 48 ++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       | 41 ++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede.h         |  5 ++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 65 ++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  6 +++
 9 files changed, 190 insertions(+), 18 deletions(-)

-- 
1.8.3.1
