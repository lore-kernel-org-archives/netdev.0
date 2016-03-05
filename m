From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v4 net-next 5/9] ARM: dts: armada-xp-openblocks-ax3-4: Add BM
 support
Date: Sat,  5 Mar 2016 23:38:23 +0100
Message-ID: <1457217507-10778-6-git-send-email-gregory.clement@free-electrons.com>
References: <1457217507-10778-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Simon Guinot <simon.guinot@sequanux.org>,
 Nadav Haklai <nadavh@marvell.com>, Timor Kardashov <timork@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Sebastian Careba <nitroshift@yahoo.com>, Marcin Wojtas <mw@semihalf.com>,
 Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457217507-10778-1-git-send-email-gregory.clement@free-electrons.com>
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

Allow Openblock AX3 using hardware buffer management with mvneta.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
index a5db17782e08..3aa29a91c7b8 100644
--- a/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
+++ b/arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
@@ -67,7 +67,8 @@
 			  MBUS_ID(0x01, 0x1d) 0 0 0xfff00000 0x100000
 			  MBUS_ID(0x01, 0x2f) 0 0 0xf0000000 0x8000000
 			  MBUS_ID(0x09, 0x09) 0 0 0xf8100000 0x10000
-			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000>;
+			  MBUS_ID(0x09, 0x05) 0 0 0xf8110000 0x10000
+			  MBUS_ID(0x0c, 0x04) 0 0 0xd1200000 0x100000>;
 
 		devbus-bootcs {
 			status = "okay";
@@ -176,21 +177,29 @@
 				status = "okay";
 				phy = <&phy0>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <0>;
 			};
 			ethernet@74000 {
 				status = "okay";
 				phy = <&phy1>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <1>;
 			};
 			ethernet@30000 {
 				status = "okay";
 				phy = <&phy2>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <2>;
 			};
 			ethernet@34000 {
 				status = "okay";
 				phy = <&phy3>;
 				phy-mode = "sgmii";
+				buffer-manager = <&bm>;
+				bm,pool-long = <3>;
 			};
 			i2c@11000 {
 				status = "okay";
@@ -219,6 +228,14 @@
 			usb@51000 {
 				status = "okay";
 			};
+
+			bm@c0000 {
+				status = "okay";
+			};
+		};
+
+		bm-bppi {
+			status = "okay";
 		};
 	};
 };
-- 
2.5.0
