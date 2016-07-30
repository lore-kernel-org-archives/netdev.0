From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 09/10] dtb: xgene: Add rxlos-gpios property
Date: Fri, 29 Jul 2016 17:34:02 -0700
Message-ID: <1469838843-19943-10-git-send-email-isubramanian@apm.com>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	linux@armlinux.org.uk, Iyappan Subramanian <isubramanian@apm.com>,
	Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35241 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbcG3Add (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 20:33:33 -0400
Received: by mail-pf0-f181.google.com with SMTP id x72so37125375pfd.2
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 17:33:33 -0700 (PDT)
In-Reply-To: <1469838843-19943-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added rxlos GPIO mapping by adding rxlos-gpios property.

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Fushen Chen <fchen@apm.com>
---
 arch/arm64/boot/dts/apm/apm-mustang.dts | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
index b7fb5d9..32a961c 100644
--- a/arch/arm64/boot/dts/apm/apm-mustang.dts
+++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
@@ -74,6 +74,7 @@
 
 &xgenet {
 	status = "ok";
+	rxlos-gpios = <&sbgpio 12 1>;
 };
 
 &mmc0 {
-- 
1.9.1
