From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 0/9] liquidio: Updates and Bug fixes
Date: Tue, 14 Jun 2016 16:54:42 -0700
Message-ID: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0084.outbound.protection.outlook.com ([65.55.169.84]:34976
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751805AbcFOAKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following are updates for liquidio bug fixes and driver
support for new firmware interface. These updates are divided
into smaller logical patches as mentioned by you. These set of
nine patches should be applied in the following order as some of
them depend on earlier patches in the list.

Thanks.

Raghu Vatsavayi (9):
  liquidio: Avoid double free during soft command
  liquidio: Host queue mapping changes
  liquidio:Scatter gather list per IQ
  liquidio:RX queue alloc changes
  liquidio: RX desc alloc changes
  liquidio: Consider PTP for packet size calculations
  liquidio: New driver FW command structure
  liquidio: Replace ifidx for FW commands
  liquidio: Introduce new octeon2/3 header


 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  41 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 715 +++++++++++----------
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 260 ++++++--
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  70 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   1 +
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 169 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  21 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  62 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  23 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  | 229 ++++++-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  35 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  | 154 +++--
 .../net/ethernet/cavium/liquidio/request_manager.c |  96 +--
 .../ethernet/cavium/liquidio/response_manager.c    |   6 +-
 14 files changed, 1218 insertions(+), 664 deletions(-)

-- 
1.8.3.1
