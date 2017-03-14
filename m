From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 20/20] ARM: sunxi: Enable dwmac-sun8i driver on multi_v7_defconfig
Date: Tue, 14 Mar 2017 15:18:56 +0100
Message-ID: <20170314141856.24560-21-clabbe.montjoie@gmail.com>
References: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Cc: f.fainelli@gmail.com, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314141856.24560-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the dwmac-sun8i driver in the multi_v7 default configuration

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/configs/multi_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 36c1b39..380919f 100644
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
