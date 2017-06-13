From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/2] pktgen new parameters
Date: Tue, 13 Jun 2017 18:04:47 +0300
Message-ID: <1497366289-22255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34391 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753239AbdFMPFJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 11:05:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset adds two parameters to the pktgen scripts.
* The first patch adds a parameter to control the number of
  packets sent by every pktgen thread.
* The second patch adds a parameter to control the index of
  first thread, instead of always starting from cpu 0.

Series generated against net-next commit:
f1c9eed7f437 bpf, arm64: take advantage of stack_depth tracking

Thanks,
Tariq.

Tariq Toukan (2):
  pktgen: Specify num packets per thread
  pktgen: Specify the index of first thread

 samples/pktgen/README.rst                          |  2 ++
 samples/pktgen/parameters.sh                       | 24 +++++++++++++++++-----
 .../pktgen/pktgen_bench_xmit_mode_netif_receive.sh |  6 +++---
 .../pktgen/pktgen_bench_xmit_mode_queue_xmit.sh    |  6 +++---
 samples/pktgen/pktgen_sample01_simple.sh           |  2 +-
 samples/pktgen/pktgen_sample02_multiqueue.sh       |  7 ++++---
 .../pktgen/pktgen_sample03_burst_single_flow.sh    |  6 +++---
 samples/pktgen/pktgen_sample04_many_flows.sh       |  6 +++---
 samples/pktgen/pktgen_sample05_flow_per_thread.sh  |  6 +++---
 9 files changed, 41 insertions(+), 24 deletions(-)

-- 
1.8.3.1
