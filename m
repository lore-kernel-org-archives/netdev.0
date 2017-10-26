From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/3] liquidio: Switchdev support for LiquidIO NIC
Date: Wed, 25 Oct 2017 22:36:41 -0700
Message-ID: <20171026053641.GA17861@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0040.outbound.protection.outlook.com ([104.47.36.40]:22123
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750884AbdJZFgq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 01:36:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>

patch1 of this patch set adds switchdev support for SRIOV capable
LiquidIO NIC, so that for every SRIOV VF on LiquidIO, a representor
netdev is created on hyperviser. It also has changes to send representor
interface configurations like admin state and MTU to LiquidIO firmware and
to retrieve HW counted VF stats for VF representor.

patch2 adds support for switchdev enable/disable from devlink

patch3 adds ethtool support for vf representor interface to return
VF representor port stats and driver info.

Vijaya Mohan Guvva (3):
  liquidio: switchdev support for LiquidIO NIC
  liquidio: Configure switchdev with devlink
  liquidio: ethtool support for switchdev ports

 drivers/net/ethernet/cavium/Kconfig                |   1 +
 drivers/net/ethernet/cavium/liquidio/Makefile      |   2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 117 ++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c  | 714 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h  |  47 ++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  51 ++
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  14 +
 7 files changed, 945 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.h

-- 
2.9.0
