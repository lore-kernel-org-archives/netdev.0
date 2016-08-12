From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 00/18] liquidio CN23XX support
Date: Fri, 12 Aug 2016 11:20:17 -0700
Message-ID: <1471026035-15323-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0080.outbound.protection.outlook.com ([104.47.41.80]:14917
	"EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752433AbcHLSzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 14:55:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following patchset adds support for new device CN23XX in
liquidio family of adapters. This V2 patch also resolved
all the comments from previous submission:
1) All cross compile issues reported by kbuild on SPARC,
   Tile, ARM platfroms.
2) Refcount issue reported by kbuild.
3) Some minor issues related to style and comments.

Please apply patches in following order as some of the
patches depend on earlier patches.

Thanks
Raghu Vatsavayi.


Raghu Vatsavayi (18):
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
  liquidio: link and control commands
  liquidio: RX control commands
  liquidio: CN23XX IQ access
  liquidio: CN23XX octeon3 instruction
  liquidio: ethtool and led control support
  liquidio: CN23XX health monitoring
  liquidio: CN23XX napi support
  liquidio: CN23XX pause frame support

 drivers/net/ethernet/cavium/Kconfig                |    4 +-
 drivers/net/ethernet/cavium/liquidio/Makefile      |   24 +-
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    | 1259 ++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |   59 +
 .../net/ethernet/cavium/liquidio/cn23xx_pf_regs.h  |  602 ++++++++++
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   12 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |    4 +-
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  271 +++++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  510 +++++++-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 1100 ++++++++++-------
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   29 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   59 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  116 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  352 ++++--
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  124 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   46 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |    2 +
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |    2 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   32 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |    1 -
 .../net/ethernet/cavium/liquidio/octeon_network.h  |    6 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |   35 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |    2 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  170 ++-
 .../ethernet/cavium/liquidio/response_manager.c    |    9 +-
 25 files changed, 4140 insertions(+), 690 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_core.c

-- 
1.8.3.1
