From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 2/3] dtb: change binding name to match with newer firmware DT
Date: Fri, 27 Feb 2015 12:08:29 -0800
Message-ID: <1425067710-14879-3-git-send-email-isubramanian@apm.com>
References: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, mlangsdo@redhat.com,
	patches@apm.com, Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:34612 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755045AbbB0UE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:04:27 -0500
Received: by pdjz10 with SMTP id z10so23442296pdj.0
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:04:26 -0800 (PST)
In-Reply-To: <1425067710-14879-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the backward compatibility of the older driver with the
newer firmware by making the binding unique so that the older driver won't
recognize the non-supported interfaces.

The new bindings are in sync with the newer firmware.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
---
 arch/arm64/boot/dts/apm/apm-storm.dtsi | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
index f1ad9c2..a857794 100644
--- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
@@ -622,7 +622,7 @@
 		};
 
 		sgenet0: ethernet@1f210000 {
-			compatible = "apm,xgene-enet";
+			compatible = "apm,xgene1-sgenet";
 			status = "disabled";
 			reg = <0x0 0x1f210000 0x0 0xd100>,
 			      <0x0 0x1f200000 0x0 0Xc300>,
@@ -636,7 +636,7 @@
 		};
 
 		xgenet: ethernet@1f610000 {
-			compatible = "apm,xgene-enet";
+			compatible = "apm,xgene1-xgenet";
 			status = "disabled";
 			reg = <0x0 0x1f610000 0x0 0xd100>,
 			      <0x0 0x1f600000 0x0 0Xc300>,
-- 
1.9.1
