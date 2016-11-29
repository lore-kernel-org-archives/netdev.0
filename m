From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 0/9] liquidio VF operations
Date: Mon, 28 Nov 2016 16:54:32 -0800
Message-ID: <1480380881-19255-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0088.outbound.protection.outlook.com ([104.47.37.88]:23744
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753542AbcK2AzF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 19:55:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchseries adds support for VF device specific operations
like mailbox, queues and register access. This V3 patchset also
has changes based on comments form earlier versions:

1) Removed extra 'void *' casting.
2) Fixed all cross compilations issues reported on S390 and Powerpc
   architectures.

Please apply the patches in following order as these patches depend
on each other.

Thanks

Raghu Vatsavayi (9):
  liquidio CN23XX: VF register definitions
  liquidio CN23XX: VF registration
  liquidio CN23XX: VF config setup
  liquidio CN23XX: VF queue setup
  liquidio CN23XX: VF register access
  liquidio CN23XX: init VF softcommand queues
  liquidio CN23XX: VF mailbox
  liquidio CN23XX: VF interrupt
  liquidio CN23XX: VF init and destroy

 drivers/net/ethernet/cavium/Kconfig                |  12 +
 drivers/net/ethernet/cavium/liquidio/Makefile      |  23 +
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 701 +++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |  48 ++
 .../net/ethernet/cavium/liquidio/cn23xx_vf_regs.h  | 274 ++++++++
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |   7 -
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 614 ++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  66 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   9 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  11 +-
 11 files changed, 1756 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c

-- 
1.8.3.1
