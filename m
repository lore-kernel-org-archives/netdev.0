From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 00/10] liquidio updates and bug fixes
Date: Sun, 3 Jul 2016 13:56:46 -0700
Message-ID: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0064.outbound.protection.outlook.com ([104.47.32.64]:21199
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932156AbcGCVaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 17:30:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Following V2 patchset contains updates and bug fixes for
liquidio driver. This patchset also has changes that you
suggested in vxlan code. Please apply the patches in following
order as some of the patches depend on earlier patches in the
series.

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

 .../net/ethernet/cavium/liquidio/cn66xx_device.c   |  22 +-
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |   2 -
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |  13 +-
 .../net/ethernet/cavium/liquidio/cn68xx_device.h   |   1 -
 drivers/net/ethernet/cavium/liquidio/cn68xx_regs.h |   1 -
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  73 +++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 325 ++++++++++++++++-----
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  35 ++-
 .../net/ethernet/cavium/liquidio/octeon_config.h   |   4 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  50 ++--
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  99 +------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   7 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |  42 +--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  20 +-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |   3 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   2 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |  24 +-
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  12 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  12 -
 .../net/ethernet/cavium/liquidio/request_manager.c |  98 ++-----
 .../ethernet/cavium/liquidio/response_manager.c    |  19 +-
 21 files changed, 433 insertions(+), 431 deletions(-)

-- 
1.8.3.1
