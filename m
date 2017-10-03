From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 0/7]crypto:chelsio: Bugs fixes
Date: Tue,  3 Oct 2017 12:16:23 +0530
Message-ID: <cover.1507010612.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:49191 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdJCGqr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 02:46:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It includes bug fix and performance improvement changes.

Harsh Jain (7):
  crypto:gf128mul: The x8_ble multiplication functions
  crypto:chelsio:Use x8_ble gf multiplication to calculate IV.
  crypto:chelsio:Remove allocation of sg list to implement 2K limit of
    dsgl header
  crypto:chelsio:Move DMA un/mapping to chcr from lld  cxgb4 driver
  crypto:chelsio: Fix memory leak
  crypto:chelsio: Remove unused parameter
  crypto:chelsio: Check error code with IS_ERR macro

 crypto/gf128mul.c                        |   13 +
 drivers/crypto/chelsio/chcr_algo.c       | 1784 +++++++++++++++++-------------
 drivers/crypto/chelsio/chcr_algo.h       |   57 +-
 drivers/crypto/chelsio/chcr_core.c       |    8 +-
 drivers/crypto/chelsio/chcr_core.h       |    2 +-
 drivers/crypto/chelsio/chcr_crypto.h     |  121 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c |    8 +-
 include/crypto/gf128mul.h                |    2 +-
 8 files changed, 1166 insertions(+), 829 deletions(-)

-- 
2.1.4
