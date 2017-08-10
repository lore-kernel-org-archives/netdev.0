From: David Wu <david.wu@rock-chips.com>
Subject: [PATCH v5 05/11] Documentation: net: phy: Add phy-is-integrated binding
Date: Thu, 10 Aug 2017 21:59:18 +0800
Message-ID: <1502373558-2558-1-git-send-email-david.wu@rock-chips.com>
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

Add the documentation for integrated PHY. A boolean property indicates
the PHY is integrated into the same physical package as the Ethernet
MAC. If needed, muxers should be configured to ensure the integrated
PHY is used. The absence of this property indicates the muxers should
be configured so that the external PHY is used.

Signed-off-by: David Wu <david.wu@rock-chips.com>
---
change in v5:
 - Use phy-is-integrated boolean property.

 Documentation/devicetree/bindings/net/phy.txt | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index b558576..d3c24d5 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -52,6 +52,11 @@ Optional Properties:
   Mark the corresponding energy efficient ethernet mode as broken and
   request the ethernet to stop advertising it.
 
+- phy-is-integrated: If set, indicates that the PHY is integrated into the same
+  physical package as the Ethernet MAC. If needed, muxers should be configured
+  to ensure the integrated PHY is used. The absence of this property indicates
+  the muxers should be configured so that the external PHY is used.
+
 Example:
 
 ethernet-phy@0 {
-- 
1.9.1
