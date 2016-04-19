From: sunil.kovvuri@gmail.com
Subject: [PATCH 0/4] net: thunderx: Add multiqset support for DPDK
Date: Tue, 19 Apr 2016 19:03:28 +0530
Message-ID: <1461072812-44239-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series mainly adds support for userspace application
like DPDK with a VNIC VF attached to request additional QSets
for having morethan the default 8 queues.

Jerin Jacob (1):
  net: thunderx: Introduce a mailbox message to reset VF counters

Radoslaw Biernacki (3):
  net: thunderx: Add multiqset support for dataplane apps
  net: thunderx: add sysfs attribute for SQS/SVF assigments
  net: thunderx: Improvement for MBX interface debug messages

 drivers/net/ethernet/cavium/thunder/nic.h        |   32 ++-
 drivers/net/ethernet/cavium/thunder/nic_main.c   |  321 +++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |   10 +-
 3 files changed, 324 insertions(+), 39 deletions(-)
