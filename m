From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 05/15] phy: hi6220: Add missing MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 17:03:31 +0900
Message-ID: <1456992221-26712-6-git-send-email-k.kozlowski__43267.4360149123$1456992326$gmane$org@samsung.com>
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
Received: from mailout4.w1.samsung.com ([210.118.77.14]:35989 "EHLO
	mailout4.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbcCCIEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:04:52 -0500
In-reply-to: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
direct dependencies.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 drivers/phy/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
index 0124d17bd9fe..cfdb3551a675 100644
--- a/drivers/phy/Kconfig
+++ b/drivers/phy/Kconfig
@@ -225,6 +225,7 @@ config PHY_MT65XX_USB3
 config PHY_HI6220_USB
 	tristate "hi6220 USB PHY support"
 	depends on (ARCH_HISI && ARM64) || COMPILE_TEST
+	depends on HAS_IOMEM	# For MFD_SYSCON
 	select GENERIC_PHY
 	select MFD_SYSCON
 	help
-- 
2.5.0
