From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 0/5] liquidio CN23XX VF support
Date: Fri, 9 Sep 2016 13:08:22 -0700
Message-ID: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0051.outbound.protection.outlook.com ([104.47.37.51]:13584
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751989AbcIIUYW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:24:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following is the initial patch series for adding support of
VF functionality on CN23XX devices. Please apply patches in
the following order as some of the patches depend on earlier
patches.

Raghu Vatsavayi (5):
  liquidio CN23XX: VF config support
  liquidio CN23XX: sriov enable
  liquidio CN23XX: Mailbox support
  liquidio CN23XX: mailbox interrupt processing
  liquidio CN23XX: VF related operations

 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 700 +++++++++++++++------
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   3 +
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  13 +-
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |  13 +-
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  32 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 366 +++++++++--
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  11 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   8 +
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  16 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  11 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  32 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  28 +-
 .../net/ethernet/cavium/liquidio/octeon_mailbox.c  | 322 ++++++++++
 .../net/ethernet/cavium/liquidio/octeon_mailbox.h  | 116 ++++
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  12 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |   9 +-
 17 files changed, 1409 insertions(+), 284 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h

-- 
1.8.3.1
