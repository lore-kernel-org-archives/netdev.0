From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 8/8] powerpc/85xx/kmcent2: use hdlc busmode for UCC1
Date: Wed, 17 May 2017 17:24:39 +0200
Message-ID: <20170517152439.8817-8-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47403 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753392AbdEQPb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:57 -0400
Received: from secmail.keymile.com ([195.8.104.201]:54693 helo=totemomail)
        by mail-de.keymile.com with smtp (Exim 4.82_1-5b7a7c0-XX)
        (envelope-from <holger.brunck@keymile.com>)
        id 1dB0pE-0000PJ-1Y
        for netdev@vger.kernel.org; Wed, 17 May 2017 17:25:20 +0200
Received: from 10.9.1.54 ([10.9.1.54])
          by secmail.keymile.com (Totemo SMTP Server) with SMTP ID 377
          for <netdev@vger.kernel.org>;
          Wed, 17 May 2017 17:26:31 +0200 (CEST)
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
---
 arch/powerpc/boot/dts/fsl/kmcent2.dts | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/powerpc/boot/dts/fsl/kmcent2.dts b/arch/powerpc/boot/dts/fsl/kmcent2.dts
index 47afa438602e..5922c1ea0e96 100644
--- a/arch/powerpc/boot/dts/fsl/kmcent2.dts
+++ b/arch/powerpc/boot/dts/fsl/kmcent2.dts
@@ -293,9 +293,7 @@
 			compatible = "fsl,ucc-hdlc";
 			rx-clock-name = "clk9";
 			tx-clock-name = "clk9";
-			fsl,tx-timeslot-mask = <0xfffffffe>;
-			fsl,rx-timeslot-mask = <0xfffffffe>;
-			fsl,siram-entry-id = <0>;
+			fsl,hdlc-bus;
 		};
 	};
 };
-- 
2.12.0.rc1
