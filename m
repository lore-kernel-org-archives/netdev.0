From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V4 00/10] liquidio CN23XX support
Date: Wed, 31 Aug 2016 11:03:19 -0700
Message-ID: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0076.outbound.protection.outlook.com ([104.47.34.76]:42304
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933101AbcHaSTB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 14:19:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following patchset adds support for new device "CN23XX" in
liquidio family of adapters. As adviced by you I have split
the previous V3 patch of 18 patches into two halves. This
first patchset has first 10 patches, which are tested against
net-next. I will post the second half after this one.

This V4 patch also addressed all the comments from previous
submission:
1) Avoid busy loop while reading registers.
2) Other minor comments about debug messages and constants.

Please apply patches in following order as some of the
patches depend on earlier patches.


Raghu Vatsavayi (10):
  liquidio: Consolidate common functionality
  liquidio: Firmware version management
  liquidio: Common enable irq function
  liquidio: CN23XX register definitions
  liquidio: CN23XX queue definitions
  liquidio: CN23XX device init and sriov config
  liquidio: CN23XX register setup
  liquidio: CN23XX queue manipulation
  liquidio: MSIX support for CN23XX
  liquidio: CN23XX firmware download

 drivers/net/ethernet/cavium/Kconfig                |    2 +-
 drivers/net/ethernet/cavium/liquidio/Makefile      |   24 +-
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 1171 ++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   57 +
 .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  |  604 ++++++++++
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   45 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |    7 +-
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |    1 -
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  261 +++++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |   18 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  766 +++++++------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   22 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   59 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  117 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  302 +++--
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  100 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   33 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |    2 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |    2 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   24 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |    1 -
 .../net/ethernet/cavium/liquidio/octeon_network.h  |    2 -
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |    8 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |    2 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |    3 +
 25 files changed, 3022 insertions(+), 611 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_core.c

-- 
1.8.3.1
