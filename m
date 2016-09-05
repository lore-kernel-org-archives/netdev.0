From: Tomer Tayar <Tomer.Tayar@qlogic.com>
Subject: [PATCH net-next 0/3] qed*: Debug data collection
Date: Mon, 5 Sep 2016 14:35:09 +0300
Message-ID: <1473075312-19075-1-git-send-email-Tomer.Tayar@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Yuval.Mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:47627 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754737AbcIELup (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 07:50:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the support of debug data collection in the qed driver,
and the means to extract it in the qede driver via the get_regs operation.

Hi Dave,

Please consider applying this to 'net-next'.

Thanks,
Tomer

Tomer Tayar (3):
  qed: Add infrastructure for debug data collection
  qed: Add support for debug data collection
  qed*: Add support for the ethtool get_regs operation

 drivers/net/ethernet/qlogic/qed/Makefile        |    2 +-
 drivers/net/ethernet/qlogic/qed/qed.h           |   20 +
 drivers/net/ethernet/qlogic/qed/qed_debug.c     | 6898 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_debug.h     |   54 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h       | 1059 +++-
 drivers/net/ethernet/qlogic/qed/qed_main.c      |    6 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       |   76 +
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       |   46 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |  900 +++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |   24 +
 include/linux/qed/common_hsi.h                  |    3 +
 include/linux/qed/qed_if.h                      |    4 +
 12 files changed, 9080 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_debug.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_debug.h

-- 
1.8.3.1
