From: Duc Dang <dhdang@apm.com>
Subject: [PATCH v3 1/2] powerpc/44x: Add new compatible value for EMAC node of APM821XX dts file.
Date: Mon,  5 Mar 2012 17:57:42 +0700
Message-ID: <1330945062-15760-1-git-send-email-dhdang@apm.com>
References: <1330920224-3006-1-git-send-email-dhdang@apm.com>
Mime-Version: 1.0
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Duc Dang <dhdang@apm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>,
	Josh Boyer <jwboyer@gmail.com>, Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og106.obsmtp.com ([64.18.0.182]:53459 "HELO
	exprod5og106.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756842Ab2CEK6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 05:58:11 -0500
Received: by dado14 with SMTP id o14so4359248dad.34
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 02:58:10 -0800 (PST)
In-Reply-To: <1330920224-3006-1-git-send-email-dhdang@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This compatible value will be used to distinguish some special features of APM821XX EMAC: no half duplex mode support, configuring jumbo frame.

Signed-off-by: Duc Dang <dhdang@apm.com>
---
v3:
 No change since v1/v2 patch sets. Added for completeness.

 arch/powerpc/boot/dts/bluestone.dts |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/powerpc/boot/dts/bluestone.dts b/arch/powerpc/boot/dts/bluestone.dts
index 2a56a0d..74876f7 100644
--- a/arch/powerpc/boot/dts/bluestone.dts
+++ b/arch/powerpc/boot/dts/bluestone.dts
@@ -222,7 +222,7 @@
 
 			EMAC0: ethernet@ef600c00 {
 				device_type = "network";
-				compatible = "ibm,emac4sync";
+				compatible = "ibm,emac-apm821xx", "ibm,emac4sync";
 				interrupt-parent = <&EMAC0>;
 				interrupts = <0x0 0x1>;
 				#interrupt-cells = <1>;
-- 
1.7.5.4
