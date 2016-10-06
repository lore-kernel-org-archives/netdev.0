From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 2/2] arm64: xgene: defconfig: Enable Standby GPIO
Date: Thu,  6 Oct 2016 14:35:58 -0700
Message-ID: <1475789758-5196-3-git-send-email-isubramanian@apm.com>
References: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
        patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35908 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935370AbcJFVdJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 17:33:09 -0400
Received: by mail-pf0-f170.google.com with SMTP id i85so14675151pfa.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 14:33:09 -0700 (PDT)
In-Reply-To: <1475789758-5196-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable CONFIG_GPIO_XGENE_SB.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 arch/arm64/configs/defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index eadf485..be52a00 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -240,6 +240,7 @@ CONFIG_GPIO_DWAPB=y
 CONFIG_GPIO_PL061=y
 CONFIG_GPIO_RCAR=y
 CONFIG_GPIO_XGENE=y
+CONFIG_GPIO_XGENE_SB=y
 CONFIG_GPIO_PCA953X=y
 CONFIG_GPIO_PCA953X_IRQ=y
 CONFIG_GPIO_MAX77620=y
-- 
1.9.1
