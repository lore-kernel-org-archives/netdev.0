From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/2] drivers: net: xgene: fix: Use GPIO to get link status
Date: Thu,  6 Oct 2016 14:35:56 -0700
Message-ID: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
        patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34399 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935431AbcJFVdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 17:33:07 -0400
Received: by mail-pa0-f43.google.com with SMTP id rz1so14047924pab.1
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 14:33:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the link value reported by the link status register is not
reliable if no SPF module inserted, this patchset fixes the issue by
using GPIO to determine the link status when no module inserted.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: fix: Use GPIO to get link status
  arm64: xgene: defconfig: Enable Standby GPIO

 arch/arm64/configs/defconfig                      |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  6 +++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 19 +++++++++++++++++--
 4 files changed, 24 insertions(+), 3 deletions(-)

-- 
1.9.1
