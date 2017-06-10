From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 0/2] net: mvpp2: driver fixes
Date: Sat, 10 Jun 2017 23:18:20 +0200
Message-ID: <20170610211822.24371-1-thomas.petazzoni@free-electrons.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:44367 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdFJVSg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 17:18:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

As requested, here is a series of patches containing only bug fixes
for the mvpp2 driver. It is based on the latest "net" branch.

Changes since v1:

 - Fixed a build breakage that occurred when only PATCH 1 was only,
   and not later patches in the series. Was reported by the kbuild
   report on the first submission.

 - Added Tested-by from Marc Zyngier on PATCH 2.

Thanks!

Thomas

Thomas Petazzoni (2):
  net: mvpp2: remove mvpp2_bm_cookie_{build,pool_get}
  net: mvpp2: use {get,put}_cpu() instead of smp_processor_id()

 drivers/net/ethernet/marvell/mvpp2.c | 74 ++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 41 deletions(-)

-- 
2.9.4
