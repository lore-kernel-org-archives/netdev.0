From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 0/8] liquidio CN23XX support
Date: Thu, 1 Sep 2016 11:16:03 -0700
Message-ID: <1472753771-21141-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0070.outbound.protection.outlook.com ([104.47.32.70]:47057
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754133AbcIAVuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:50:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I am posting the remaining half of patchset after the
acceptance of first half. With this patchset I am able
to completely submit the code of V3 patchset  which you
earlier advised me to split into smaller ones.

This V5 patch also addresses all the comments from previous
submission:
1) Avoid busy loop while reading registers.
2) Other minor comments about debug messages and constants.

Please apply patches in following order as some of the
patches depend on earlier patches.

Raghu Vatsavayi (8):
  liquidio: link and control commands
  liquidio: RX control commands
  liquidio: CN23XX IQ access
  liquidio: CN23XX octeon3 instruction
  liquidio: ethtool and led control support
  liquidio: CN23XX health monitoring
  liquidio: CN23XX napi support
  liquidio:CN23XX pause frame support

 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    |  66 +++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   2 +
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  11 +-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 495 ++++++++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 360 +++++++++++++--
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  12 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  50 ++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  14 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  13 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   8 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  10 +
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  27 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |   4 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 167 +++++--
 .../ethernet/cavium/liquidio/response_manager.c    |   9 +-
 15 files changed, 1128 insertions(+), 120 deletions(-)

-- 
1.8.3.1
