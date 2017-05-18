From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 0/2] Check all RGMII phy mode variants
Date: Thu, 18 May 2017 15:13:42 -0700
Message-ID: <1495145624-29463-1-git-send-email-isubramanian@apm.com>
Cc: f.fainelli@gmail.com, andrew@lunn.ch,
        linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36708 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932412AbdERWKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 18:10:50 -0400
Received: by mail-pg0-f41.google.com with SMTP id x64so28816527pgd.3
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 15:10:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set,
     - adds phy_interface_mode_is_rgmii() helper function
     - addresses review comment from previous patch set, by calling
       phy_interface_mode_is_rgmii() to address all RGMII variants

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
v2: Address review comments from v1
     - adds phy_interface_mode_is_rgmii() helper function
     - addresses review comment from previous patch set, by calling
       phy_interface_mode_is_rgmii() to address all RGMII variants
v1:
     - Initial version
---

Iyappan Subramanian (2):
  include: linux: Add helper function to check phy interface mode
  drivers: net: xgene: Check all RGMII phy mode variants

 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c |  6 +++---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c      | 12 ++++++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c    | 15 +++++++++------
 include/linux/phy.h                                 | 14 ++++++++++++--
 4 files changed, 30 insertions(+), 17 deletions(-)

-- 
1.9.1
