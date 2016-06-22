From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 00/13] liquidio: updates and bug fixes
Date: Tue, 21 Jun 2016 22:53:02 -0700
Message-ID: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0095.outbound.protection.outlook.com ([207.46.100.95]:26294
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750816AbcFVGJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 02:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Please consider following patch series for liquidio bug fixes
and updates on top of net-next. Following patches should be
applied in the following order as some of them depend on
earlier patches in the series.

-Raghu.

Raghu Vatsavayi (13):
  liquidio: soft command buffer limits
  liquidio: Vlan offloads changes
  liquidio: Vlan filtering
  liquidio: Napi rx/tx traffic
  liquidio: Firmware image download
  liquidio: New unload state
  liquidio: chip reset changes
  liquidio: tx rx interrupt moderation
  liquidio: New statistics support
  liquidio: New xaui info
  liquidio: ptp info
  liquidio: Support priv flag
  liquidio: ddr timeout

 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  39 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   3 +-
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 899 ++++++++++++++++-----
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 398 ++++++---
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 127 +--
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  12 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 100 +--
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  44 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  20 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  11 +
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  20 +-
 .../net/ethernet/cavium/liquidio/request_manager.c | 116 ++-
 .../ethernet/cavium/liquidio/response_manager.c    |   2 +
 14 files changed, 1328 insertions(+), 465 deletions(-)

-- 
1.8.3.1
