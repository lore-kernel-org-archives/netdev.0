From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Subject: [RFC 12/15] soc: qcom: Add missing MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 17:03:38 +0900
Message-ID: <1456992221-26712-13-git-send-email-k.kozlowski__39291.0145492808$1456992395$gmane$org@samsung.com>
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
Received: from mailout1.w1.samsung.com ([210.118.77.11]:58200 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288AbcCCIFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 03:05:52 -0500
In-reply-to: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MFD_SYSCON depends on HAS_IOMEM so when selecting it avoid unmet
direct dependencies.

Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
---
 drivers/soc/qcom/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/soc/qcom/Kconfig b/drivers/soc/qcom/Kconfig
index 461b387d03cc..24de48134c15 100644
--- a/drivers/soc/qcom/Kconfig
+++ b/drivers/soc/qcom/Kconfig
@@ -4,6 +4,7 @@
 config QCOM_GSBI
         tristate "QCOM General Serial Bus Interface"
         depends on ARCH_QCOM
+        depends on HAS_IOMEM	# For MFD_SYSCON
         select MFD_SYSCON
         help
           Say y here to enable GSBI support.  The GSBI provides control
-- 
2.5.0
