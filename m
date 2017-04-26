From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/9] drivers: net: xgene: Add ethtool stats and bug fixes
Date: Wed, 26 Apr 2017 16:38:46 -0700
Message-ID: <1493249935-30759-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35089 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032745AbdDZXge (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:36:34 -0400
Received: by mail-pf0-f181.google.com with SMTP id v14so8272186pfd.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:36:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set,

- adds ethtool extended statistics support
- addresses errata workarounds
- fixes bugs related to statistics

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---

Quan Nguyen (9):
  drivers: net: xgene: Protect indirect MAC access
  drivers: net: xgene: Remove redundant local stats
  drivers: net: xgene: Refactor statistics error parsing code
  drivers: net: xgene: Remove unused macros
  drivers: net: xgene: Extend ethtool statistics
  drivers: net: xgene: Add rx_overrun/tx_underrun statistic
  drivers: net: xgene: Workaround for HW errata 10GE_4
  drivers: net: xgene: Add frame recovered statistics counter for errata
    10GE_8/ENET_11
  drivers: net: xgene: Workaround for HW errata 10GE_10/ENET_15

 .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 132 ++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  41 ++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  66 +++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |  57 ++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  13 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  |  42 ++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c  |  35 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.h  |   5 +
 8 files changed, 357 insertions(+), 34 deletions(-)

-- 
1.9.1
