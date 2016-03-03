From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 06/15] pinctrl: rockchip: Add missing MFD_SYSCON dependency on
 HAS_IOMEM
Date: Thu, 03 Mar 2016 17:03:32 +0900
Message-ID: <1456992221-26712-7-git-send-email-k.kozlowski__21420.3879623257$1456992337$gmane$org@samsung.com>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>
To: Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dan Williams <dan.j.williams@intel.com>,
	Vinod Koul <vinod.koul@intel.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Lee Jones <lee.jones@linaro.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Sebastian Reichel <sre@kernel.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Alessandro Zummo <a.zummo@towertech.it>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andy Gross <andy.gross@linaro.org>,
	David Brown <david.brown@linaro.org>,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, dmaen
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:58116 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932338AbcCCIE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:04:59 -0500
In-reply-to: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
direct dependencies.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 drivers/pinctrl/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/pinctrl/Kconfig b/drivers/pinctrl/Kconfig
index fb8200b8e8ec..dc7ab58d4d74 100644
--- a/drivers/pinctrl/Kconfig
+++ b/drivers/pinctrl/Kconfig
@@ -131,6 +131,7 @@ config PINCTRL_MESON
 
 config PINCTRL_ROCKCHIP
 	bool
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select PINMUX
 	select GENERIC_PINCONF
 	select GENERIC_IRQ_CHIP
-- 
2.5.0
