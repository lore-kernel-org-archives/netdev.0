From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 0/2] liquidio: Add support for managing liquidio
 adapter
Date: Fri, 28 Jul 2017 23:17:07 -0700
Message-ID: <20170729061707.GA1134@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0062.outbound.protection.outlook.com ([104.47.33.62]:51200
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750902AbdG2GRP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 02:17:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

The LiquidIO adapter has processor cores that can run Linux. This patch
set adds support to create a virtual Ethernet interface on host to
communicate with applications running on Linux in the LiquidIO adapter.
The virtual Ethernet interface also provides login access to Linux on
LiquidIO through ssh for management and debugging.

Change Log:
V1 -> V2
 Only patch #2 was changed:
   * Removed inline functions in .c files
   * Removed useless, almost-empty functions
   * Revised if-statement under "/* Check for all conditions ..."
   * Replaced "if (skb_shinfo(skb)->nr_frags == 0)" with
       "if (!skb_shinfo(skb)->nr_frags)"

Veerasenareddy Burru (2):
  liquidio: Add support to pass meta information to firmware
  liquidio: Add support to create management interface

 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  17 +-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  21 ++
 .../net/ethernet/cavium/liquidio/liquidio_mgmt.c   | 351 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  28 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   8 +
 7 files changed, 423 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c

-- 
1.8.3.1
