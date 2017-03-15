From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/7] drivers: net: xgene: Bug fixes and errata workarounds
Date: Wed, 15 Mar 2017 13:27:14 -0700
Message-ID: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35282 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdCOU0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:04 -0400
Received: by mail-pf0-f170.google.com with SMTP id x63so8273551pfx.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses bug fixes and errata workarounds.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---

Iyappan Subramanian (3):
  drivers: net: xgene: Fix Rx checksum validation logic
  drivers: net: xgene: Add workaround for errata 10GE_8/ENET_11
  MAINTAINERS: Update X-Gene SoC ethernet maintainer

Quan Nguyen (4):
  drivers: net: phy: xgene: Fix mdio write
  drivers: net: xgene: Fix hardware checksum setting
  drivers: net: xgene: Fix wrong logical operation
  drivers: net: xgene: Add workaround for errata 10GE_1

 MAINTAINERS                                       |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 74 ++++++++++++++---------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  7 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h |  5 ++
 drivers/net/phy/mdio-xgene.c                      |  2 +-
 8 files changed, 65 insertions(+), 30 deletions(-)

-- 
1.9.1
