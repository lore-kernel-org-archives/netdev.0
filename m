From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/4] drivers: net: xgene-v2: Add MDIO and ethtool support
Date: Tue, 21 Mar 2017 12:24:39 -0700
Message-ID: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
        f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35264 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933247AbdCUTYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 15:24:34 -0400
Received: by mail-pf0-f179.google.com with SMTP id 20so35970925pfk.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 12:23:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set,
    
- adds phy management and ethtool support
- fixes ethernet reset
- addresses review comments from previous patch set

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (4):
  drivers: net: xgene-v2: Add MDIO support
  drivers: net: xgene-v2: Add ethtool support
  drivers: net: xgene-v2: Fix port reset
  drivers: net: xgene-v2: misc fixes

 drivers/net/ethernet/apm/xgene-v2/Makefile  |   2 +-
 drivers/net/ethernet/apm/xgene-v2/enet.c    |  24 +++-
 drivers/net/ethernet/apm/xgene-v2/enet.h    |   2 +
 drivers/net/ethernet/apm/xgene-v2/ethtool.c | 121 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/mac.c     |   2 +-
 drivers/net/ethernet/apm/xgene-v2/mac.h     |   2 +-
 drivers/net/ethernet/apm/xgene-v2/main.c    |  69 ++++++-----
 drivers/net/ethernet/apm/xgene-v2/main.h    |   6 +
 drivers/net/ethernet/apm/xgene-v2/mdio.c    | 178 ++++++++++++++++++++++++++++
 9 files changed, 365 insertions(+), 41 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ethtool.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mdio.c

-- 
1.9.1
