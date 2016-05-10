From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/6] drivers: net: xgene: Bug fixes
Date: Mon,  9 May 2016 17:04:10 -0700
Message-ID: <1462838656-22043-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33147 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbcEJADt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 20:03:49 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so78282531pac.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 17:03:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses the following bug fixes that were found during testing.

  1. IPv4 forward test crash
    - drivers: net: xgene: fix IPv4 forward crash

  2. Sharing of irqs
    - drivers: net: xgene: fix sharing of irqs

  3. Ununiform latency across queues
    - drivers: net: xgene: fix ununiform latency across queues

  4. Fix statistics counters race condition
    - drivers: net: xgene: fix statistics counters race condition

  5. TSO data corruption
    - drivers: net: xgene: Using static MSS values

  6. Correcting register offset and field lengths
    - drivers: net: xgene: fix register offset

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (6):
  drivers: net: xgene: fix IPv4 forward crash
  drivers: net: xgene: fix sharing of irqs
  drivers: net: xgene: fix ununiform latency across queues
  drivers: net: xgene: fix statistics counters race condition
  drivers: net: xgene: Using static MSS values
  drivers: net: xgene: fix register offset

 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c   |  11 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h   |   2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  19 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  10 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 118 ++++++++++++++++++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  24 +++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |   2 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  20 +++-
 8 files changed, 159 insertions(+), 47 deletions(-)

-- 
1.9.1
