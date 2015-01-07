From: Peter Griffin <peter.griffin@linaro.org>
Subject: [PATCH v2 6/7] ARM: multi_v7_defconfig: Enable stih407 usb picophy
Date: Wed,  7 Jan 2015 15:04:11 +0000
Message-ID: <1420643052-4506-7-git-send-email-peter.griffin@linaro.org>
References: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org>
Cc: peter.griffin@linaro.org, lee.jones@linaro.org,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	srinivas.kandagatla@gmail.com, maxime.coquelin@st.com,
	patrice.chotard@st.com, peppe.cavallaro@st.com, kishon@ti.com,
	arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420643052-4506-1-git-send-email-peter.griffin@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables the picoPHY usb phy which is used by
the usb2 and usb3 host controllers when controlling usb2/1.1
devices. It is found in stih407 family SoC's from STMicroelectronics.

Signed-off-by: Peter Griffin <peter.griffin@linaro.org>
Acked-by: Lee Jones <lee.jones@linaro.org>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/arm/configs/multi_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index bc393b7..444685c 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -456,6 +456,7 @@ CONFIG_OMAP_USB2=y
 CONFIG_TI_PIPE3=y
 CONFIG_PHY_MIPHY365X=y
 CONFIG_PHY_STIH41X_USB=y
+CONFIG_PHY_STIH407_USB=y
 CONFIG_PHY_SUN4I_USB=y
 CONFIG_EXT4_FS=y
 CONFIG_AUTOFS4_FS=y
-- 
1.9.1
