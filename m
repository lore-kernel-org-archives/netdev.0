From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/4] Updates for samples/pktgen
Date: Wed, 01 Nov 2017 11:41:04 +0100
Message-ID: <150953283424.29671.6809291616813585256.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert@herjulf.se>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        robert.hu@intel.com, pabeni@redhat.com, kafai@fb.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30813 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752071AbdKAKlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:41:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset updates samples/pktgen and synchronize with changes
maintained in https://github.com/netoptimizer/network-testing/

Features wise Robert Hoo <robert.hu@intel.com> added support for
detecting and determining dev NUMA node IRQs, and added a new script
named pktgen_sample06_numa_awared_queue_irq_affinity.sh that use these
features.

Cleanup remove last of the old sample files, as IPv6 is covered by
existing sample code.

---

Jesper Dangaard Brouer (2):
      samples/pktgen: update sample03, no need for clones when bursting
      samples/pktgen: remove remaining old pktgen sample scripts

Robert Hoo (2):
      samples/pktgen: Add some helper functions
      samples/pktgen: add script pktgen_sample06_numa_awared_queue_irq_affinity.sh


 samples/pktgen/functions.sh                        |   43 +++++++++
 samples/pktgen/pktgen.conf-1-1-ip6                 |   60 ------------
 samples/pktgen/pktgen.conf-1-1-ip6-rdos            |   63 -------------
 samples/pktgen/pktgen.conf-1-2                     |   69 --------------
 .../pktgen/pktgen_sample03_burst_single_flow.sh    |    2 
 ...tgen_sample06_numa_awared_queue_irq_affinity.sh |   97 ++++++++++++++++++++
 6 files changed, 141 insertions(+), 193 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-ip6
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-ip6-rdos
 delete mode 100755 samples/pktgen/pktgen.conf-1-2
 create mode 100755 samples/pktgen/pktgen_sample06_numa_awared_queue_irq_affinity.sh
