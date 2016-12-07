From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 0/7] liquidio VF data path
Date: Wed, 7 Dec 2016 08:54:30 -0800
Message-ID: <1481129677-10586-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0084.outbound.protection.outlook.com ([104.47.37.84]:43712
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932681AbcLGQyz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 11:54:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following is V3 patch series that adds support for VF
data path related features. It also has following changes
related to previous comments:
1) Remove unnecessary "void *" casting.
2) Remove inline for functions and let gcc decide.

Please apply patches in following order as some of them
depend on earlier patches.

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
