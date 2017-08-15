From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/4] liquidio: adding support for ethtool
 --set-channels feature
Date: Tue, 15 Aug 2017 12:45:15 -0700
Message-ID: <20170815194515.GA2188@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0075.outbound.protection.outlook.com ([104.47.32.75]:26448
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752031AbdHOTpR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 15:45:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Code reorganization is required for adding ethtool --set-channels feature.
First three patches are for code reorganization.  The last patch is for
adding this feature.

Intiyaz Basha (4):
  liquidio: moved liquidio_msix_intr_handler to lio_core.c
  liquidio: moved liquidio_legacy_intr_handler to lio_core.c
  liquidio: moved octeon_setup_interrupt to lio_core.c
  liquidio: added support for ethtool --set-channels feature

 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 307 ++++++++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 190 +++++++++++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 295 ++------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 171 ++----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   3 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   6 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   8 +-
 7 files changed, 529 insertions(+), 451 deletions(-)

-- 
2.9.0
