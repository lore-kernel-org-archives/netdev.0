From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH V4 6/7] ARM: OMAP2+: omap2plus_defconfig: Enable CPSW support
Date: Tue, 6 Nov 2012 23:02:38 +0530
Message-ID: <1352223159-27504-7-git-send-email-mugunthanvnm@ti.com>
References: <1352223159-27504-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:41016 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158Ab2KFRc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 12:32:59 -0500
In-Reply-To: <1352223159-27504-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable CPSW support in defconfig which is present in AM33xx SoC

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/arm/configs/omap2plus_defconfig |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/arch/arm/configs/omap2plus_defconfig b/arch/arm/configs/omap2plus_defconfig
index a4b330e..41b595e 100644
--- a/arch/arm/configs/omap2plus_defconfig
+++ b/arch/arm/configs/omap2plus_defconfig
@@ -242,3 +242,6 @@ CONFIG_CRC_ITU_T=y
 CONFIG_CRC7=y
 CONFIG_LIBCRC32C=y
 CONFIG_SOC_OMAP5=y
+CONFIG_TI_DAVINCI_MDIO=y
+CONFIG_TI_DAVINCI_CPDMA=y
+CONFIG_TI_CPSW=y
-- 
1.7.0.4
