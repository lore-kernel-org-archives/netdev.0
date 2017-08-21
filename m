From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 0/2] liquidio: VF driver will notify NIC firmware
 of MTU change
Date: Mon, 21 Aug 2017 12:35:27 -0700
Message-ID: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0042.outbound.protection.outlook.com ([104.47.34.42]:53280
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753222AbdHUTfE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:35:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

Make VF driver notify NIC firmware of MTU change.  Firmware needs this
information for MTU propagation and enforcement.

The first patch in this series moves a macro definition to a proper place
to prevent a build error in the second patch which has the code that sends
the notification.

Change Log:
  V1 -> V2
    * Add "From:" line to patch #1 and #2 to give credit to the author.
    * In patch #2, order local variable declarations from longest to
      shortest line.

Veerasenareddy Burru (2):
  liquidio: move macro definition to a proper place
  liquidio: make VF driver notify NIC firmware of MTU change

 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |  2 --
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 27 ++++++++++++++++++----
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  2 ++
 3 files changed, 24 insertions(+), 7 deletions(-)

-- 
2.9.0
