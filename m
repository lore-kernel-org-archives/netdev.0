From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/8] liquidio: adding support for ethtool --set-ring
 feature
Date: Fri, 11 Aug 2017 18:28:18 -0700
Message-ID: <20170812012818.GA2505@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:13109
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751721AbdHLB20 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 21:28:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Code reorganization is required for adding ethtool --set-ring feature.
First seven patches are for code reorganization.  The last patch is for
adding this feature.

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
