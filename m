From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] qed*: driver updates
Date: Sun, 9 Oct 2016 18:25:32 +0300
Message-ID: <1476026738-26069-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:44755 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751554AbcJIPaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 11:30:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>

There are several new additions in this series;
Most are connected to either Tx offloading or Rx classifications
[either fastpath changes or supporting configuration].

In addition, there's a single IOV enhancement.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Manish Chopra (2):
  qede: GSO support for tunnels with outer csum
  qede: Prevent GSO on long Geneve headers

Yuval Mintz (4):
  qed: Pass MAC hints to VFs
  qed*: Allow unicast filtering
  qed: Allow chance for fast ramrod completions
  qed: Handle malicious VFs events

 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  12 ++-
 drivers/net/ethernet/qlogic/qed/qed_spq.c    |  85 ++++++++++++++------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 114 ++++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |   1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h     |   1 +
 drivers/net/ethernet/qlogic/qede/qede.h      |   1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c |  71 +++++++++++++++--
 include/linux/qed/qed_eth_if.h               |   3 +-
 9 files changed, 236 insertions(+), 56 deletions(-)

-- 
1.9.3
