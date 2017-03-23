From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH v3 net 0/5] net:ethernet:aquantia: Misc fixes for atlantic driver.
Date: Thu, 23 Mar 2017 14:19:40 +0300
Message-ID: <cover.1490267633.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0079.outbound.protection.outlook.com ([104.47.37.79]:2176
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754631AbdCWLUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 07:20:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The following patchset containg several fixes for aQuantia AQtion driver
for net tree: A couple fixes for IPv6 and other fixes.

v1->v2: Fix compilation error (using HW_ATL_A0_TXD_CTL_CMD_IPV6 instead
        HW_ATL_B0_TXD_CTL_CMD_IPV6).
v2->v3: Added "Fixes" tags.

Pavel Belous (5):
  net:ethernet:aquantia: Remove adapter re-opening when MTU changed.
  net:ethernet:aquantia: Fix packet type detection (TCP/UDP) for IPv6.
  net:ethernet:aquantia: Missing spinlock initialization.
  net:ethernet:aquantia: Fix for LSO with IPv6.
  net:ethernet:aquantia: Reset is_gso flag when EOP reached.

 drivers/net/ethernet/aquantia/atlantic/aq_main.c   |  5 -----
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 23 ++++++++++++++++++----
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   |  1 +
 drivers/net/ethernet/aquantia/atlantic/aq_ring.h   |  3 ++-
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  4 ++++
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  4 ++++
 6 files changed, 30 insertions(+), 10 deletions(-)

-- 
2.7.4
