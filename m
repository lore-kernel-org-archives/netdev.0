From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 0/7] qed*: driver updates
Date: Thu, 13 Oct 2016 07:22:44 -0400
Message-ID: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
        Manish Chopra <manish.chopra@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33200 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754339AbcJMMIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 08:08:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@caviumnetworks.com>

Hi David,

There are several new additions in this series;
Most are connected to either Tx offloading or Rx classifications
[either fastpath changes or supporting configuration].

In addition, there's a single IOV enhancement.

Please consider applying this series to `net-next'.

V2:
Added a fix for the race in ramrod handling
pointed by Eric Dumazet [patch 7].

Thanks,
Manish

Manish Chopra (3):
  qede: GSO support for tunnels with outer csum
  qede: Prevent GSO on long Geneve headers
  qed: Fix possible race when reading firmware return code.

Yuval Mintz (4):
  qed: Pass MAC hints to VFs
  qed*: Allow unicast filtering
  qed: Allow chance for fast ramrod completions
  qed: Handle malicious VFs events

 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  12 ++-
 drivers/net/ethernet/qlogic/qed/qed_spq.c    |  97 +++++++++++++++--------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c  | 114 ++++++++++++++++++++++-----
 drivers/net/ethernet/qlogic/qed/qed_sriov.h  |   1 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c     |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_vf.h     |   1 +
 drivers/net/ethernet/qlogic/qede/qede.h      |   1 +
 drivers/net/ethernet/qlogic/qede/qede_main.c |  71 +++++++++++++++--
 include/linux/qed/qed_eth_if.h               |   3 +-
 9 files changed, 242 insertions(+), 62 deletions(-)

-- 
2.7.2
