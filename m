From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net v2 0/4] net:ethernet:aquantia: Atlantic driver bugfixes und improvements
Date: Mon, 25 Sep 2017 10:48:46 +0300
Message-ID: <cover.1506324091.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0053.outbound.protection.outlook.com ([104.47.33.53]:29696
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbdIYHtT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 03:49:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains bugfixes for aQuantia Atlantic driver.

Changes in v2:
Review comments applied:
- min_mtu set removed
- extra mtu range check is removed
- err codes handling improved

Igor Russkikh (3):
  net:ethernet:aquantia: Setup max_mtu in ndev to enable jumbo frames
  net:ethernet:aquantia: Fix Tx queue hangups
  net:ethernet:aquantia: Fix transient invalid link down/up indications

Pavel Belous (1):
  net:ethernet:atlantic: fix iommu errors

 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h    |   4 +
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 145 ++++++++++-----------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |   2 -
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  53 ++++++--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  10 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    |   8 +-
 .../aquantia/atlantic/hw_atl/hw_atl_b0_internal.h  |   2 +-
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        |   3 +-
 8 files changed, 129 insertions(+), 98 deletions(-)

-- 
2.7.4
