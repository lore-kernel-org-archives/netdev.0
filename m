From: Guodong Xu <guodong.xu@linaro.org>
Subject: [PATCH 2/2] arm64: dts: hikey: set bluetooth led trigger
Date: Thu, 23 Jun 2016 12:58:43 +0800
Message-ID: <1466657923-5776-2-git-send-email-guodong.xu@linaro.org>
References: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Guodong Xu <guodong.xu@linaro.org>
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net, xuwei5@hisilicon.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	haojian.zhuang@linaro.org, linus.walleij@linaro.org,
	tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33265 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbcFWE72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 00:59:28 -0400
Received: by mail-pa0-f50.google.com with SMTP id b13so23629902pat.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 21:59:28 -0700 (PDT)
In-Reply-To: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set bluetooth led trigger to hci0-rx, and so LED blinks on hci
frame receiving.

Signed-off-by: Guodong Xu <guodong.xu@linaro.org>
---
 arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts b/arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts
index e92a30c..5032792 100644
--- a/arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts
+++ b/arch/arm64/boot/dts/hisilicon/hi6220-hikey.dts
@@ -132,7 +132,7 @@
 		bt_active_led {
 			label = "bt_active";
 			gpios = <&gpio4 7 0>; /* <&gpio_bt_active_led>; */
-			linux,default-trigger = "hci0rx";
+			linux,default-trigger = "hci0-rx";
 			default-state = "off";
 		};
 	};
-- 
1.9.1
