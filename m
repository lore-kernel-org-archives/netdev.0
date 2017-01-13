From: Harsh Jain <harsh@chelsio.com>
Subject: [PATCH v1 0/4]crypto:chcr- Bug Fixes for 4.10
Date: Fri, 13 Jan 2017 17:59:19 +0530
Message-ID: <cover.1484309965.git.harsh@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
        herbert@gondor.apana.org.au, linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:45114 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdAMM3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 07:29:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is based on Herbert's cryptodev-2.6 tree.
It includes several critical bug fixes.

Atul Gupta (3):
  crypto:chcr-Change flow IDs
  crypto:chcr- Fix panic on dma_unmap_sg
  crypto:chcr- Check device is allocated before use
Julia Lawall (1):
  crypto:chcr-fix itnull.cocci warnings

 drivers/crypto/chelsio/chcr_algo.c            | 67 ++++++++++++++-------------
 drivers/crypto/chelsio/chcr_algo.h            |  9 ++--
 drivers/crypto/chelsio/chcr_core.c            | 18 ++++---
 drivers/crypto/chelsio/chcr_core.h            |  1 +
 drivers/crypto/chelsio/chcr_crypto.h          |  3 ++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |  8 ++++
 6 files changed, 61 insertions(+), 45 deletions(-)

-- 
1.8.2.3
