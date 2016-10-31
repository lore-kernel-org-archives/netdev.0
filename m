From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/2] drivers: net: xgene: Fix coalescing bugs
Date: Mon, 31 Oct 2016 16:00:25 -0700
Message-ID: <1477954827-9951-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36592 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947895AbcJaXAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 19:00:23 -0400
Received: by mail-oi0-f53.google.com with SMTP id v84so97866339oie.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 16:00:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set fixes the following,

     1. Since ethernet v1 hardware has a bug related to coalescing,
	disabling this feature
     2. Fixing ethernet v2 hardware, interrupt trigger region
	id to 2, to kickoff coalescing

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>

---

Iyappan Subramanian (2):
  drivers: net: xgene: fix: Disable coalescing on v1 hardware
  drivers: net: xgene: fix: Coalescing values for v2 hardware

 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 12 ------------
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  3 ++-
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c | 12 +++++++-----
 4 files changed, 11 insertions(+), 18 deletions(-)

-- 
1.9.1
