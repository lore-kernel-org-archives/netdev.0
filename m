From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 2/3][RESEND] powerpc: dts: p1022si: Add fsl,wake-on-filer for eTSEC
Date: Mon, 5 Oct 2015 17:19:58 +0300
Message-ID: <1444054799-17876-2-git-send-email-claudiu.manoil@freescale.com>
References: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Zhao Chenhui <chenhui.zhao@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0128.outbound.protection.outlook.com ([65.55.169.128]:16105
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751351AbbJEOjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 10:39:55 -0400
In-Reply-To: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the "wake-on-filer" (aka. wake on user defined packet)
wake on lan capability for the eTSEC ethernet nodes.

Cc: Li Yang <leoli@freescale.com>
Cc: Zhao Chenhui <chenhui.zhao@freescale.com>

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
Patch initially sent to the ppc-devel list,
resend it to the netdev list:
http://patchwork.ozlabs.org/patch/524904/

 arch/powerpc/boot/dts/fsl/p1022si-post.dtsi | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/powerpc/boot/dts/fsl/p1022si-post.dtsi b/arch/powerpc/boot/dts/fsl/p1022si-post.dtsi
index 426bf41..5f51b7b 100644
--- a/arch/powerpc/boot/dts/fsl/p1022si-post.dtsi
+++ b/arch/powerpc/boot/dts/fsl/p1022si-post.dtsi
@@ -224,10 +224,12 @@
 
 /include/ "pq3-etsec2-0.dtsi"
 	enet0: enet0_grp2: ethernet@b0000 {
+		fsl,wake-on-filer;
 	};
 
 /include/ "pq3-etsec2-1.dtsi"
 	enet1: enet1_grp2: ethernet@b1000 {
+		fsl,wake-on-filer;
 	};
 
 	global-utilities@e0000 {
-- 
1.7.11.7
