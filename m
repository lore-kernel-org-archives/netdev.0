From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 0/2] qed*: PTP bug fixes.
Date: Tue, 2 May 2017 01:11:01 -0700
Message-ID: <20170502081103.4252-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0055.outbound.protection.outlook.com ([104.47.41.55]:53973
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750886AbdEBIL2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 04:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The series addresses couple of issues in the PTP implementation.

Please consider applying it to 'net' branch.

Sudarsana Reddy Kalluru (2):
  qede: Fix concurrency issue in PTP Tx path processing.
  qed*: Fix issues in the ptp filter config implementation.

 drivers/net/ethernet/qlogic/qed/qed_ptp.c   | 84 ++++++++++++++++++-----------
 drivers/net/ethernet/qlogic/qede/qede.h     |  3 +-
 drivers/net/ethernet/qlogic/qede/qede_ptp.c | 38 ++++++++++---
 include/linux/qed/qed_eth_if.h              | 23 +++++---
 4 files changed, 104 insertions(+), 44 deletions(-)

-- 
1.8.3.1
