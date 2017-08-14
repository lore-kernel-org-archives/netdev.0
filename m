From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 0/8] liquidio: adding support for ethtool
 --set-ring feature
Date: Mon, 14 Aug 2017 12:00:34 -0700
Message-ID: <20170814190034.GA1219@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0085.outbound.protection.outlook.com ([104.47.34.85]:20864
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752202AbdHNTAx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 15:00:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Code reorganization is required for adding ethtool --set-ring feature.
First seven patches are for code reorganization.  The last patch is for
adding this feature.

Change Log:
V1 -> V2
 Only patch #8 was changed:  unnecessary parentheses were removed in two
 if-statements in lio_ethtool_set_ringparam().

Intiyaz Basha (8):
  liquidio: moved wait_for_pending_requests to octeon_network.h
  liquidio: moved update_txq_status to lio_core.c
  liquidio: moved octeon_setup_droq to lio_core.c
  liquidio: moved liquidio_push_packet to lio_core.c
  liquidio: moved liquidio_napi_drv_callback to lio_core.c
  liquidio: moved liquidio_napi_poll to lio_core.c
  liquidio: moved liquidio_setup_io_queues to lio_core.c
  liquidio: added support for ethtool --set-ring feature

 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |   2 -
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 424 +++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 131 ++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 448 +--------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 379 +----------------
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  13 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  14 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  29 ++
 9 files changed, 617 insertions(+), 825 deletions(-)

-- 
2.9.0
