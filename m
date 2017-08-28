From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net v2 0/6] net:ethernet:aquantia: Atlantic driver Update 2017-08-23
Date: Mon, 28 Aug 2017 21:52:07 +0300
Message-ID: <cover.1503945861.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, David Arcari <darcari@redhat.com>,
        Igor Russkikh <Igor.Russkikh@aquantia.com>,
        Nadezhda Krupnina <Nadezhda.Krupnina@aquantia.com>,
        Simon Edelhaus <simon.edelhaus@aquantia.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0048.outbound.protection.outlook.com ([104.47.34.48]:4736
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751192AbdH1Swx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 14:52:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This series contains updates for aQuantia Atlantic driver.

It has bugfixes and some improvements.

Changes in v2:
 - "MCP state change" fix removed (will be sent as
    a separate fix after further investigation.)

Igor Russkikh (1):
  net:ethernet:aquantia: Fix for multicast filter handling.

Pavel Belous (5):
  net:ethernet:aquantia: Extra spinlocks removed.
  net:ethernet:aquantia: Fix for number of RSS queues.
  net:ethernet:aquantia: Workaround for HW checksum bug.
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
 .../aquantia/atlantic/hw_atl/hw_atl_utils.c        | 10 ++-
 .../aquantia/atlantic/hw_atl/hw_atl_utils.h        |  3 +-
 9 files changed, 68 insertions(+), 65 deletions(-)

-- 
2.7.4
