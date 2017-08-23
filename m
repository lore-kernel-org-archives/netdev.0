From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 0/3] net: mvpp2: software TSO support
Date: Wed, 23 Aug 2017 09:46:53 +0200
Message-ID: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55998 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753455AbdHWHrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:47:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This series adds the s/w TSO support in the PPv2 driver, in addition to
two cosmetic commits. As stated in patch 3/3:

Using iperf and 10G ports, using TSO shows a significant performance
improvement by a factor 2 to reach around 9.5Gbps in TX; as well as a
significant CPU usage drop (from 25% to 15%).

Thanks!
Antoine

Antoine Tenart (3):
  net: define the TSO header size in net/tso.h
  net: mvpp2: unify the txq size define use
  net: mvpp2: software tso support

 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   1 -
 drivers/net/ethernet/freescale/fec_main.c          |   1 -
 drivers/net/ethernet/marvell/mv643xx_eth.c         |   2 -
 drivers/net/ethernet/marvell/mvneta.c              |   3 -
 drivers/net/ethernet/marvell/mvpp2.c               | 182 ++++++++++++++++++---
 include/net/tso.h                                  |   2 +
 6 files changed, 164 insertions(+), 27 deletions(-)

-- 
2.13.5
