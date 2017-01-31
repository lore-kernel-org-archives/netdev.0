From: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Subject: [PATCH net-next v3 0/2] qed*: Add support for PTP
Date: Mon, 30 Jan 2017 23:47:47 -0800
Message-ID: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
        <Yuval.Mintz@cavium.com>,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0062.outbound.protection.outlook.com ([104.47.37.62]:4496
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750776AbdAaHsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 02:48:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Hi David,
    The patch series adds required changes for qed/qede drivers for
supporting the IEEE Precision Time Protocol (PTP).

Please consider applying this series to "net-next".

Thanks,
Sudarsana

Changes from previous versions:
-------------------------------
v3: Use div_s64 for 64-bit divisions as do_div gives error for signed
    types.
    Incorporated review comments from Richard Cochran.
      - Clear timestamp resgisters as soon as timestamp is read.
      - Use shift operation in the place of 'divide by 16'.

v2: Use do_div for 64-bit divisions.

Sudarsana Reddy Kalluru (2):
  qed: Add infrastructure for PTP support.
  qede: Add driver support for PTP.

 drivers/net/ethernet/qlogic/Kconfig             |   1 +
 drivers/net/ethernet/qlogic/qed/Makefile        |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h           |   2 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c        |   5 +
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |   1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  15 +
 drivers/net/ethernet/qlogic/qed/qed_ptp.c       | 318 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ptp.h       |  47 +++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |  31 ++
 drivers/net/ethernet/qlogic/qede/Makefile       |   2 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  10 +
 drivers/net/ethernet/qlogic/qede/qede_fp.c      |   5 +
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  39 ++
 drivers/net/ethernet/qlogic/qede/qede_ptp.c     | 536 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_ptp.h     |  65 +++
 include/linux/qed/qed_eth_if.h                  |  22 +
 17 files changed, 1103 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.h

-- 
1.8.3.1
