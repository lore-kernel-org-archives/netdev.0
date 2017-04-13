From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 0/2] qed/qede: aRFS support
Date: Thu, 13 Apr 2017 04:54:43 -0700
Message-ID: <20170413115445.16662-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0067.outbound.protection.outlook.com ([104.47.40.67]:48715
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751473AbdDMLzH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 07:55:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series adds support for Accelerated Flow Steering
in qede driver for TCP/UDP over IPv4/IPv6 protocols.

Please consider applying this series to "net-next"

Thanks,
Manish

Manish Chopra (2):
  qed: aRFS infrastructure support
  qede: Add aRFS support

 drivers/net/ethernet/qlogic/qed/qed.h              |   2 +
 drivers/net/ethernet/qlogic/qed/qed_cxt.c          |  13 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h          | 187 +++++++++
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    | 129 ++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.c           | 133 +++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.h           |   8 +
 drivers/net/ethernet/qlogic/qed/qed_main.c         |  26 ++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h     |   8 +
 drivers/net/ethernet/qlogic/qed/qed_sp.h           |   1 +
 drivers/net/ethernet/qlogic/qede/qede.h            |  22 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c     | 441 +++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  50 ++-
 include/linux/qed/qed_eth_if.h                     |   8 +
 include/linux/qed/qed_if.h                         |   7 +
 14 files changed, 1027 insertions(+), 8 deletions(-)

-- 
2.7.2
