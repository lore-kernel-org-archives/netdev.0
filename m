From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/2] drivers: net: xgene: fix irq related issues
Date: Tue,  8 Mar 2016 21:49:35 -0800
Message-ID: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36649 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbcCIFtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 00:49:15 -0500
Received: by mail-pf0-f181.google.com with SMTP id u190so1931920pfb.3
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 21:49:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set addresses,

	1. Remove static association of prefetch buffers and derive that from Linux irq
	2. Remove irq sharing

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: fix: Derive prefetch number from irq
  drivers: net: xgene: fix: Remove IRQF_SHARED flag

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 19 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  6 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 13 +++++--------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  7 +------
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c | 12 ++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h |  4 ++++
 6 files changed, 47 insertions(+), 14 deletions(-)

-- 
1.9.1
