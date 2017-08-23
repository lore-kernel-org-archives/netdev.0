From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net 0/7] net:ethernet:aquantia: Atlantic driver Update 2017-08-23
Date: Wed, 23 Aug 2017 17:05:01 +0300
Message-ID: <cover.1503496727.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0059.outbound.protection.outlook.com ([104.47.34.59]:20167
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754034AbdHWOFd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 10:05:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This series contains updates for aQuantia Atlantic driver.

It has bugfixes and some improvements.

Igor Russkikh (1):
  net:ethernet:aquantia: Fix for multicast filter handling.

Pavel Belous (6):
  net:ethernet:aquantia: Extra spinlocks removed.
  net:ethernet:aquantia: Fix for number of RSS queues.
  net:ethernet:aquantia: Workaround for HW checksum bug.
  net:ethernet:aquantia: Fix for MCP state change.
  net:ethernet:aquantia: Fix for incorrect speed index.
  net:ethernet:aquantia: Show info message if bad firmware version
    detected.

 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     |  3 +-
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 92 +++++++++++-----------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  1 -
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h  |  1 -
 drivers/net/ethernet/aquantia/atlantic/aq_vec.c    | 11 +--
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  6 ++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  6 ++
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        | 17 ++--
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        | 16 +++-
 9 files changed, 85 insertions(+), 68 deletions(-)

-- 
2.7.4
