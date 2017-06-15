From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 0/9] Bug fixes and ctr mode of operation
Date: Thu, 15 Jun 2017 12:43:38 +0530
Message-ID: <cover.1497506936.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:34874 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdFOHOB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:14:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is based on cryptodev2.6 tree and includes bug fix ,ctr(aes), rfc3686(ctr(aes)) algo.

Harsh Jain (7):
  crypto: chcr - Pass lcb bit setting to firmware
  crypto: chcr - Set fallback key
  crypto: chcr - Return correct error code
  crypto: chcr - Avoid changing request structure
  crypto:chcr - Add ctr mode and process large sg entries for cipher
  MAINTAINERS:Add maintainer for chelsio crypto driver
  crypto: chcr - Ensure Destination sg entry size less than      2k
Atul Gupta (2):
  chcr - Add debug counters
  crypto: chcr - Select device in Round Robin fashion

 MAINTAINERS                                        |    7 +
 drivers/crypto/chelsio/chcr_algo.c                 | 1096 ++++++++++++++++----
 drivers/crypto/chelsio/chcr_algo.h                 |   30 +-
 drivers/crypto/chelsio/chcr_core.c                 |   56 +-
 drivers/crypto/chelsio/chcr_core.h                 |    5 +-
 drivers/crypto/chelsio/chcr_crypto.h               |   25 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   35 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c     |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   10 +
 10 files changed, 1020 insertions(+), 246 deletions(-)

-- 
1.8.3.1
