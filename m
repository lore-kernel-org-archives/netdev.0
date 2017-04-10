From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH 0/4]  Bug fixes and fallback for AEAD
Date: Mon, 10 Apr 2017 18:23:57 +0530
Message-ID: <cover.1491807106.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org, atul.gupta@chelsio.com,
        ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:12785 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752963AbdDJMxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:53:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series based on Herbert cryptodev-2.6.
It includes bug fixes and fallback for AEAD algos.

Harsh Jain (3):
  chcr: Increase priority of AEAD algos.
  chcr:Set hmac_ctrl bit to use HW register HMAC_CFG[456].
  chcr: Add fallback for AEAD algos
Atul Gupta (1):
  chcr: Fix txq ids

 drivers/crypto/chelsio/chcr_algo.c              |  298 ++++++++++++++---------
 drivers/crypto/chelsio/chcr_algo.h              |    4 +
 drivers/crypto/chelsio/chcr_core.h              |    2 +
 drivers/crypto/chelsio/chcr_crypto.h            |   10 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    9 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    3 +-
 7 files changed, 210 insertions(+), 117 deletions(-)
