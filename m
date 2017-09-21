From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 0/4] net:ethernet:aquantia: Atlantic driver bugfixes and improvements
Date: Thu, 21 Sep 2017 13:53:38 +0300
Message-ID: <cover.1505915085.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0058.outbound.protection.outlook.com ([104.47.40.58]:29618
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751387AbdIUKyU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 06:54:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains bugfixes for aQuantia Atlantic driver.

Igor Russkikh (3):
  net:ethernet:aquantia: Setup max_mtu in ndev to enable jumbo frames
  net:ethernet:aquantia: Fix Tx queue hangups
  net:ethernet:aquantia: Fix transient invalid link down/up indications

Pavel Belous (1):
  net:ethernet:atlantic: fix iommu errors

 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h    |   4 +
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 139 ++++++++++-----------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |   2 -
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  53 ++++++--
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  10 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    |   8 +-
 .../aquantia/atlantic/hw_atl/hw_atl_b0_internal.h  |   2 +-
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        |   3 +-
 8 files changed, 130 insertions(+), 91 deletions(-)

-- 
2.7.4
