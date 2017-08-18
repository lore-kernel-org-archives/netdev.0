From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 0/2] liquidio: VF driver will notify NIC firmware of
 MTU change
Date: Fri, 18 Aug 2017 11:34:32 -0700
Message-ID: <20170818183432.GA4487@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0058.outbound.protection.outlook.com ([104.47.36.58]:28183
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750971AbdHRSeX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 14:34:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

Make VF driver notify NIC firmware of MTU change.  Firmware needs this
information for MTU propagation and enforcement.

The first patch in this series moves a macro definition to a proper place
to prevent a build error in the second patch which has the code that sends
the notification.

Veerasenareddy Burru (2):
  liquidio: move macro definition to a proper place
  liquidio: make VF driver notify NIC firmware of MTU change

 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |  2 --
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 22 ++++++++++++++++++----
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  2 ++
 3 files changed, 20 insertions(+), 6 deletions(-)

-- 
2.9.0
