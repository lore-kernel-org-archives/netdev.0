From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH RESEND net 0/9] Fixes, cleanup and modernization for some legacy ethernet NIC drivers
Date: Mon,  2 Oct 2017 21:07:17 -0400 (EDT)
Message-ID: <cover.1506992619.git.fthain@telegraphics.com.au>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kvm5.telegraphics.com.au ([98.124.60.144]:35234 "EHLO
        kvm5.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdJCBHS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 21:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes some logging bugs and adds some missing message
severity levels.

There are also cleanup patches for dead code and some Kconfig cruft.

Custom debug message logging is converted to netif_* calls to reduce
code duplication.

All up, about 150 lines of code are eliminated.

My apologies for duplicated messages. I messed up the addressing.


Finn Thain (9):
  net/smc9194: Remove bogus CONFIG_MAC reference
  net/mac89x0: Remove dead or unreachable code
  net/mac89x0: Fix and modernize log messages
  net/mac89x0: Replace custom debug logging with netif_* calls
  net/macmace: Fix and cleanup log messages
  net/sonic: Cleanup and modernize log messages
  net/sonic: Replace custom debug logging with netif_* calls
  net/8390: Fix redundant code
  net/mac8390: Fix log messages

 drivers/net/ethernet/8390/ax88796.c      |   3 -
 drivers/net/ethernet/8390/axnet_cs.c     |   2 -
 drivers/net/ethernet/8390/etherh.c       |  17 -----
 drivers/net/ethernet/8390/hydra.c        |   4 --
 drivers/net/ethernet/8390/lib8390.c      |   2 +
 drivers/net/ethernet/8390/mac8390.c      |  42 +++++-------
 drivers/net/ethernet/8390/mcf8390.c      |   4 --
 drivers/net/ethernet/8390/pcnet_cs.c     |   4 --
 drivers/net/ethernet/8390/zorro8390.c    |   5 --
 drivers/net/ethernet/apple/macmace.c     |  10 +--
 drivers/net/ethernet/cirrus/mac89x0.c    | 109 ++++++++-----------------------
 drivers/net/ethernet/natsemi/jazzsonic.c |  26 ++------
 drivers/net/ethernet/natsemi/macsonic.c  |  45 ++++---------
 drivers/net/ethernet/natsemi/sonic.c     |  92 +++++++++++++-------------
 drivers/net/ethernet/natsemi/sonic.h     |   2 +
 drivers/net/ethernet/natsemi/xtsonic.c   |  28 ++------
 drivers/net/ethernet/smsc/Kconfig        |   2 +-
 17 files changed, 123 insertions(+), 274 deletions(-)

-- 
2.13.5
