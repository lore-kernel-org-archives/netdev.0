From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 20/20] ARM: sunxi: Enable dwmac-sun8i driver on multi_v7_defconfig
Date: Mon,  3 Apr 2017 11:14:44 +0200
Message-ID: <20170403091444.29876-21-clabbe.montjoie@gmail.com>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35730 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751435AbdDCJRt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 05:17:49 -0400
In-Reply-To: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the dwmac-sun8i driver in the multi_v7 default configuration

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/configs/multi_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 2196206..0af325b 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -257,6 +257,7 @@ CONFIG_SMSC911X=y
 CONFIG_STMMAC_ETH=y
 CONFIG_STMMAC_PLATFORM=y
 CONFIG_DWMAC_DWC_QOS_ETH=y
+CONFIG_DWMAC_SUN8I=y
 CONFIG_TI_CPSW=y
 CONFIG_XILINX_EMACLITE=y
 CONFIG_AT803X_PHY=y
-- 
2.10.2
