From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 0/9] liquidio VF operations
Date: Mon, 28 Nov 2016 00:50:29 -0800
Message-ID: <1480323038-13702-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0085.outbound.protection.outlook.com ([104.47.34.85]:8992
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754112AbcK1Iu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 03:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchseries adds support for VF device specific operations
like mailbox, queues and register access. I also removed extra 'void *'
casting that was reported in V1 patch. Please apply the patches in
following order as these patches depend on each other.

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
 drivers/net/ethernet/cavium/liquidio/Makefile      |  22 +
 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    | 701 +++++++++++++++++++++
 .../ethernet/cavium/liquidio/cn23xx_vf_device.h    |  48 ++
 .../net/ethernet/cavium/liquidio/cn23xx_vf_regs.h  | 274 ++++++++
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |   7 -
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |   6 +-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 614 ++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  66 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   9 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  11 +-
 11 files changed, 1755 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_device.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_vf_regs.h
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c

-- 
1.8.3.1
