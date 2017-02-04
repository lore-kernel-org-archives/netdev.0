From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 00/12] net: get rid of __napi_complete()
Date: Sat,  4 Feb 2017 15:24:50 -0800
Message-ID: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33305 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdBDXZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:07 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so14439319pfb.0
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes __napi_complete() calls, in an effort
to make NAPI API simpler and generalize GRO and napi_complete_done()

Eric Dumazet (12):
  8139too: use napi_complete_done()
  8139cp: use napi_complete_done()
  epic100: use napi_complete_done()
  amd8111e: add GRO support
  pcnet32: use napi_complete_done()
  ep93xx_eth: add GRO support
  skge: use napi_complete_done()
  ks8695net: add GRO support
  qla3xxx: add GRO support
  ibm/emac: use napi_complete_done()
  aeroflex/greth: use napi_complete_done()
  net: remove __napi_complete()

 drivers/net/ethernet/aeroflex/greth.c    |   2 +-
 drivers/net/ethernet/amd/amd8111e.c      | 164 ++++++++++++++-----------------
 drivers/net/ethernet/amd/pcnet32.c       |  11 +--
 drivers/net/ethernet/cirrus/ep93xx_eth.c |  29 ++----
 drivers/net/ethernet/ibm/emac/mal.c      |  18 ++--
 drivers/net/ethernet/marvell/skge.c      |   8 +-
 drivers/net/ethernet/micrel/ks8695net.c  |  11 +--
 drivers/net/ethernet/qlogic/qla3xxx.c    |  31 +++---
 drivers/net/ethernet/realtek/8139cp.c    |  11 +--
 drivers/net/ethernet/realtek/8139too.c   |   8 +-
 drivers/net/ethernet/smsc/epic100.c      |  31 ++----
 include/linux/netdevice.h                |   1 -
 net/core/dev.c                           |  24 +----
 13 files changed, 127 insertions(+), 222 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
