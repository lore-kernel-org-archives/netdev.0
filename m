From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH v2 00/11] net: mvpp2: misc improvements and preparation patches
Date: Tue, 27 Dec 2016 17:54:09 +0100
Message-ID: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:36624 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754449AbcL0Qyb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 11:54:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This series contains a number of misc improvements and preparation
patches for an upcoming series that adds support for the new PPv2.2
network controller to the mvpp2 driver.

The most significant improvements are:

 - Switching to using build_skb(), which is necessary for the upcoming
   PPv2.2 support, but anyway a good improvement to the current mvpp2
   driver (supporting PPv2.1).

 - Making the driver build on 64-bit platforms.

Changes since v1:

 - This series is split as a separate series from the larger patch set
   adding support for PPv2.2 in the mvpp2 driver, as requested by
   David Miller.

 - Rebased on top of v4.10-rc1.

Thanks!

Thomas

Thomas Petazzoni (11):
  net: mvpp2: handle too large value handling in
    mvpp2_rx_pkts_coal_set()
  net: mvpp2: handle too large value in mvpp2_rx_time_coal_set()
  net: mvpp2: release reference to txq_cpu[] entry after unmapping
  net: mvpp2: remove unused 'tx_skb' field of 'struct mvpp2_tx_queue'
  net: mvpp2: drop useless fields in mvpp2_bm_pool and related code
  net: mvpp2: simplify mvpp2_bm_bufs_add()
  net: mvpp2: remove unused register definitions
  net: mvpp2: fix indentation of MVPP2_EXT_GLOBAL_CTRL_DEFAULT
  net: mvpp2: simplify MVPP2_PRS_RI_* definitions
  net: mvpp2: switch to build_skb() in the RX path
  net: mvpp2: enable building on 64-bit platforms

 drivers/net/ethernet/marvell/Kconfig |   3 +-
 drivers/net/ethernet/marvell/mvpp2.c | 161 ++++++++++++++++++++---------------
 2 files changed, 93 insertions(+), 71 deletions(-)

-- 
2.7.4
