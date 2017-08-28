From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v3 13/13] arm64: defconfig: enable Marvell CP110 comphy
Date: Mon, 28 Aug 2017 16:57:25 +0200
Message-ID: <20170828145725.2539-14-antoine.tenart@free-electrons.com>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Cc: Miquel Raynal <miquel.raynal@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org,
        Antoine Tenart <antoine.tenart@free-electrons.com>
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miquel Raynal <miquel.raynal@free-electrons.com>

The comphy is an hardware block giving access to common PHYs that can be
used by various other engines (Network, SATA, ...). This is used on
Marvell 7k/8k platforms for now. Enable the corresponding driver.

Signed-off-by: Miquel Raynal <miquel.raynal@free-electrons.com>
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 arch/arm64/configs/defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index 6b26a05ae5b4..d453ba50df43 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -510,6 +510,7 @@ CONFIG_PWM_TEGRA=m
 CONFIG_PHY_RCAR_GEN3_USB2=y
 CONFIG_PHY_HI6220_USB=y
 CONFIG_PHY_SUN4I_USB=y
+CONFIG_PHY_MVEBU_CP110_COMPHY=y
 CONFIG_PHY_ROCKCHIP_INNO_USB2=y
 CONFIG_PHY_ROCKCHIP_EMMC=y
 CONFIG_PHY_ROCKCHIP_PCIE=m
-- 
2.13.5
