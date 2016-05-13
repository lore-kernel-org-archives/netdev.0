From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/5] drivers: net: xgene: Bug fixes
Date: Fri, 13 May 2016 16:52:56 -0700
Message-ID: <1463183581-30475-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35062 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbcEMXwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 19:52:07 -0400
Received: by mail-pa0-f51.google.com with SMTP id iv1so45191079pac.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 16:52:07 -0700 (PDT)
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

  5. Correcting register offset and field lengths
    - drivers: net: xgene: fix register offset

v2: Address review comments from v1
- Defer TSO fix, and reposting all other patches from v1

v1:
- Initial version

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (5):
  drivers: net: xgene: fix IPv4 forward crash
  drivers: net: xgene: fix sharing of irqs
  drivers: net: xgene: fix ununiform latency across queues
  drivers: net: xgene: fix statistics counters race condition
  drivers: net: xgene: fix register offset

 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c   | 11 ++--
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h   |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 19 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  8 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 75 +++++++++++++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  | 18 ++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.h |  2 +-
 7 files changed, 94 insertions(+), 41 deletions(-)

-- 
1.9.1
