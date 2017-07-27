From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v2 02/11] multi_v7_defconfig: Make rockchip phy built-in
Date: Thu, 27 Jul 2017 20:55:47 +0800
Message-ID: <1501160156-30328-3-git-send-email-david.wu@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: huangtao@rock-chips.com, hwg@rock-chips.com, alexandre.torgue@st.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
 David Wu <david.wu@rock-chips.com>, peppe.cavallaro@st.com,
 linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, heiko@sntech.de, andrew@lunn.ch, f.fainelli@gmail.com,
 robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
 will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Enable the rockchip phy for multi_v7_defconfig builds.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
 arch/arm/configs/multi_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 4d19c1b..94d7e71 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -270,6 +270,7 @@ CONFIG_ICPLUS_PHY=y
 CONFIG_REALTEK_PHY=y
 CONFIG_MICREL_PHY=y
 CONFIG_FIXED_PHY=y
+CONFIG_ROCKCHIP_PHY=y
 CONFIG_USB_PEGASUS=y
 CONFIG_USB_RTL8152=m
 CONFIG_USB_USBNET=y
-- 
1.9.1
