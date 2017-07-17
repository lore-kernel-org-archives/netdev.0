From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/2] liquidio: Add support for managing liquidio
 adapter
Date: Mon, 17 Jul 2017 12:50:46 -0700
Message-ID: <20170717195046.GA1191@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0068.outbound.protection.outlook.com ([104.47.36.68]:50352
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751316AbdGQTsg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 15:48:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

The LiquidIO adapter has processor cores that can run Linux. This patch
adds support to create a virtual Ethernet interface on host to
communicate with applications running on Linux in the LiquidIO adapter.
The virtual Ethernet interface also provides login access to Linux on
LiquidIO through ssh for management and debugging.

VSR Burru (2):
  liquidio: Add support to pass meta information to firmware
  liquidio: Add support to create management interface

 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  17 +-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  21 ++
 .../net/ethernet/cavium/liquidio/liquidio_mgmt.c   | 397 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  28 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   2 +
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   9 +
 7 files changed, 470 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c

-- 
2.9.0
