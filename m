From: Tomer Tayar <Tomer.Tayar@qlogic.com>
Subject: [PATCH v2 net-next 0/2] qed*: Debug data collection
Date: Wed, 7 Sep 2016 16:36:23 +0300
Message-ID: <1473255385-1702-1-git-send-email-Tomer.Tayar@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yuval.mintz@qlogic.com>, Tomer Tayar <Tomer.Tayar@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:39159 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756803AbcIGNgc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 09:36:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds the support of debug data collection in the qed driver,
and the means to extract it in the qede driver via the get_regs operation.

Hi Dave,

Please consider applying this to 'net-next'.

Thanks,
Tomer

Changes from V1:
- Respin of the series after rebasing next-next.
- Remove the first patch as it seems that its V1 version was already applied
  (commit '4102426f9b7b3627c8c23a54d70363e81c93f9b7').

Tomer Tayar (2):
  qed: Add support for debug data collection
  qed*: Add support for the ethtool get_regs operation

 drivers/net/ethernet/qlogic/qed/Makefile        |    2 +-
 drivers/net/ethernet/qlogic/qed/qed.h           |   20 +
 drivers/net/ethernet/qlogic/qed/qed_debug.c     | 6898 +++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_debug.h     |   54 +
 drivers/net/ethernet/qlogic/qed/qed_hsi.h       | 1056 +++-
 drivers/net/ethernet/qlogic/qed/qed_main.c      |    6 +
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |  894 +++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |   24 +
 include/linux/qed/common_hsi.h                  |    3 +
 include/linux/qed/qed_if.h                      |    4 +
 10 files changed, 8949 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_debug.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_debug.h

-- 
1.8.3.1
