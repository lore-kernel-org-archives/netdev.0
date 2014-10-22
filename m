From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 8/9] ARM: berlin: Add phy-connection-type to BG2Q Ethernet
Date: Wed, 22 Oct 2014 20:26:51 +0200
Message-ID: <1414002412-13615-9-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1414002412-13615-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414002412-13615-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Antoine T=C3=A9nart <antoine.tenart@free-electrons.com>

Internal FastEthernet PHY on BG2Q is connected via MII, add a
corresponding phy-connection-type property to the Ethernet node.

Tested-by: Antoine T=C3=A9nart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Changelog:
v1->v2:
- add phy-connection-type to controller node instead of PHY node
  (Reported by Sergei Shtylyov)

Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: devicetree@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/boot/dts/berlin2q.dtsi | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/boot/dts/berlin2q.dtsi b/arch/arm/boot/dts/berlin=
2q.dtsi
index 891d56b03922..6bd01add3984 100644
--- a/arch/arm/boot/dts/berlin2q.dtsi
+++ b/arch/arm/boot/dts/berlin2q.dtsi
@@ -123,6 +123,7 @@
 			local-mac-address =3D [00 00 00 00 00 00];
 			#address-cells =3D <1>;
 			#size-cells =3D <0>;
+			phy-connection-type =3D "mii";
 			phy-handle =3D <&ethphy0>;
 			status =3D "disabled";
=20
--=20
2.1.1
