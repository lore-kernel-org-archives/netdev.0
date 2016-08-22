From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/4] qed*: IOV patch series
Date: Mon, 22 Aug 2016 13:25:08 +0300
Message-ID: <1471861512-30104-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:46048 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750839AbcHVKZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent FW [8.10.10.0] enabled us to support sriov interaction
with legacy VF/PF. This patch series adds the necessary driver changes
to utilize this additional compatibility.
In addition, utilize the new FW ability to prevent pause floods by VFs,
and fix a bug that is [mostly] exposed by the added legacy support.

Dave,

Please consider apply this to 'net-next'.

Thanks,
Yuval

Yuval Mintz (4):
  qed: Add support for legacy VFs
  qed: Prevent VFs from pause flooding
  qed*: Add support for VFs over legacy PFs
  qed: Change locking scheme for VF channel

 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  20 ++-
 drivers/net/ethernet/qlogic/qed/qed_l2.h     |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 110 +++++++++++--
 drivers/net/ethernet/qlogic/qed/qed_vf.c     | 231 ++++++++++++++++++++-------
 drivers/net/ethernet/qlogic/qed/qed_vf.h     |   7 +-
 drivers/net/ethernet/qlogic/qede/qede.h      |   2 +
 drivers/net/ethernet/qlogic/qede/qede_main.c |  10 ++
 include/linux/qed/qed_eth_if.h               |   3 +
 8 files changed, 309 insertions(+), 79 deletions(-)

-- 
1.9.3
