From: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Subject: [PATCH net-next v2 0/2] qed*: Add support for PTP
Date: Sat, 28 Jan 2017 23:28:21 -0800
Message-ID: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0040.outbound.protection.outlook.com ([104.47.38.40]:1305
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750720AbdA2H3A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 02:29:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

Hi David,
    The patch series adds required changes for qed/qede drivers for
supporting the IEEE Precision Time Protocol (PTP).

Changes from previous versions:
-------------------------------
v2: Use do_div for 64-bit divisions


Please consider applying this series to "net-next".

Thanks,
Sudarsana

Sudarsana Reddy Kalluru (2):
  qed: Add infrastructure for PTP support.
  qede: Add driver support for PTP.

 drivers/net/ethernet/qlogic/Kconfig             |   1 +
 drivers/net/ethernet/qlogic/qed/Makefile        |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h           |   2 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c        |   5 +
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |   1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  15 +
 drivers/net/ethernet/qlogic/qed/qed_ptp.c       | 319 ++++++++++++++
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
 17 files changed, 1104 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.h

-- 
1.8.3.1
