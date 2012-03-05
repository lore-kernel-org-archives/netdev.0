From: Duc Dang <dhdang@apm.com>
Subject: [PATCH v2 1/2] powerpc/44x: Add new compatible value for EMAC node of APM821XX dts file.
Date: Mon,  5 Mar 2012 11:00:19 +0700
Message-ID: <1330920019-2957-1-git-send-email-dhdang@apm.com>
References: <1329466058-15969-1-git-send-email-dhdang@apm.com>
Mime-Version: 1.0
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Duc Dang <dhdang@apm.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>,
	Josh Boyer <jwboyer@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329466058-15969-1-git-send-email-dhdang@apm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This compatible value will be used to distinguish some special features of APM821XX EMAC: no half duplex mode support, configuring jumbo frame.

Signed-off-by: Duc Dang <dhdang@apm.com>
---
v2:
 No change since v1 patch set. Added for completeness.

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
