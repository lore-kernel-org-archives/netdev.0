From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 0/7] liquidio VF data path
Date: Tue, 6 Dec 2016 13:06:00 -0800
Message-ID: <1481058367-3937-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0082.outbound.protection.outlook.com ([104.47.34.82]:23072
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751396AbcLFVVD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 16:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following patch series adds support for VF data path
related features. I have removed unnecessary "void *"
casting. Please apply patches in following order as 
some of them depend on earlier patches.

Raghu Vatsavayi (7):
  liquidio CN23XX: VF offload features
  liquidio CN23XX: VF link status
  liquidio CN23XX: VF mac address
  liquidio CN23XX: VF scatter gather lists
  liquidio CN23XX: VF xmit
  liquidio CN23XX: VF TX buffers
  liquidio VF rx data and ctl path

 .../ethernet/cavium/liquidio/cn23xx_vf_device.c    |   21 +
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 2094 +++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |    1 +
 .../net/ethernet/cavium/liquidio/octeon_device.c   |    5 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   10 +
 .../net/ethernet/cavium/liquidio/octeon_network.h  |    1 +
 .../net/ethernet/cavium/liquidio/request_manager.c |    6 +-
 .../ethernet/cavium/liquidio/response_manager.c    |    3 +-
 8 files changed, 2124 insertions(+), 17 deletions(-)

-- 
1.8.3.1
