From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 00/10] liquidio updates and bug fixes
Date: Tue, 28 Jun 2016 17:54:22 -0700
Message-ID: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752423AbcF2AzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following are some more updates and bug fixes for liquidio driver.
Please apply the patches in following order as some of the patches
depend on earlier patches in the sereis.

Raghu Vatsavayi (10):
  liquidio: Vxlan support
  liquidio: Macro replacements
  liquidio: IQ synchronization
  liquidio: softcommand delay
  liquidio: iq/oq limits
  liquidio: free resources during shutdown
  liquidio: MTU limits
  liquidio: Droq validation
  liquidio: Remove redundant code
  liquidio: Response header changes

 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |   8 +-
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |   1 -
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  61 ++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 333 +++++++++++++++++----
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  31 +-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   4 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  33 +-
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  14 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   6 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  32 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |   6 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   3 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   2 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |   9 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  14 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |  84 ++----
 .../ethernet/cavium/liquidio/response_manager.c    |   5 +-
 17 files changed, 447 insertions(+), 199 deletions(-)

-- 
1.8.3.1
