From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 0/8] crypto:chcr- Bug fixes
Date: Fri,  6 Jan 2017 14:01:31 +0530
Message-ID: <cover.1483599449.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:41121 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939658AbdAFIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 03:32:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch series is based on Herbert's cryptodev-2.6 tree.
It include bug fixes.

Atul Gupta (4):
  crypto:chcr-Change flow IDs
  crypto:chcr- Fix panic on dma_unmap_sg
  crypto:chcr- Check device is allocated before use
  crypto:chcr- Fix wrong typecasting
Harsh Jain (4):
  crypto:chcr- Fix key length for RFC4106
  crypto:chcr- Use cipher instead of Block Cipher in gcm setkey
  crypto:chcr: Change cra_flags for cipher algos
  crypto:chcr- Change algo priority


 drivers/crypto/chelsio/chcr_algo.c            | 97 ++++++++++++++-------------
 drivers/crypto/chelsio/chcr_algo.h            |  9 +--
 drivers/crypto/chelsio/chcr_core.c            | 27 ++++----
 drivers/crypto/chelsio/chcr_core.h            |  1 +
 drivers/crypto/chelsio/chcr_crypto.h          |  5 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  8 +++
 6 files changed, 80 insertions(+), 67 deletions(-)

-- 
1.8.2.3
