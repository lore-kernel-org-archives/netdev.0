From: Igor Russkikh <igor.russkikh@aquantia.com>
Subject: [PATCH net 0/7] net: aquantia: Atlantic driver 10/2017 updates
Date: Thu, 19 Oct 2017 18:23:52 +0300
Message-ID: <cover.1508159232.git.igor.russkikh@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Igor Russkikh <igor.russkikh@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0058.outbound.protection.outlook.com ([104.47.32.58]:61587
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750902AbdJSPYa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 11:24:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes various issues in driver,
improves parameters for better performance on 10Gbit link

Igor Russkikh (7):
  net: aquantia: Reset nic statistics on interface up/down
  net: aquantia: Add queue restarts stats counter
  net: aquantia: Fixed transient link up/down/up notification
  net: aquantia: Limit number of MSIX irqs to the number of cpus
  net: aquantia: mmio unmap was not performed on driver removal
  net: aquantia: Enable coalescing management via ethtool interface
  net: aquantia: Bad udp rate on default interrupt coalescing

 drivers/net/ethernet/aquantia/atlantic/aq_cfg.h    |   8 +-
 .../net/ethernet/aquantia/atlantic/aq_ethtool.c    | 157 +++++++++++++--------
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |   5 +-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    |  39 +++--
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    |   4 +-
 .../net/ethernet/aquantia/atlantic/aq_pci_func.c   |  14 +-
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    |   3 +
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  21 ++-
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  89 ++++++------
 .../aquantia/atlantic/hw_atl/hw_atl_b0_internal.h  |   3 +
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        |  69 +++++++--
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |  18 ++-
 12 files changed, 284 insertions(+), 146 deletions(-)

-- 
2.7.4
