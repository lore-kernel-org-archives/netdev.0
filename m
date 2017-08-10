From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 03/11] arm64: defconfig: Enable CONFIG_ROCKCHIP_PHY
Date: Thu, 10 Aug 2017 21:56:42 +0800
Message-ID: <1502373410-2423-4-git-send-email-david.wu@rock-chips.com>
References: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Wu <david.wu@rock-chips.com>
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502373410-2423-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the rockchip PHY driver built into the kernel.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm64/configs/defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index 6c7d147..925bd478 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -203,6 +203,7 @@ CONFIG_MARVELL_PHY=m
 CONFIG_MESON_GXL_PHY=m
 CONFIG_MICREL_PHY=y
 CONFIG_REALTEK_PHY=m
+CONFIG_ROCKCHIP_PHY=y
 CONFIG_USB_PEGASUS=m
 CONFIG_USB_RTL8150=m
 CONFIG_USB_RTL8152=m
-- 
1.9.1
