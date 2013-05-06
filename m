From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 6/7] ARM: kirkwood: add gigabit ethernet and mvmdio device
 tree nodes
Date: Mon,  6 May 2013 17:33:39 +0200
Message-ID: <1367854420-8006-7-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>, Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>,
 Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
 Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Willy Tarreau <w@1wt.eu>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

This patch adds mv643xx_eth and mvmdio device tree nodes for DT enabled
Kirkwood boards. Phy nodes are also added with reg property set on a
per-board basis.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Cc: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>
Cc: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Cc: Michael Walle <michael-QKn5cuLxLXY@public.gmane.org>
Cc: Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Willy Tarreau <w@1wt.eu>
Cc: Simon Baatz <gmbnomis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>
Cc: Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Cc: Stefan Peter <s.peter-R0yVo0h44Ow@public.gmane.org>
Cc: Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>
Cc: Nobuhiro Iwamatsu <iwamatsu-+mkmVskJBflAfugRpC6u6w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   15 ++++++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   15 ++++++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   15 ++++++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   26 ++++++++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   15 ++++++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   26 ++++++++++
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |   15 ++++++
 arch/arm/boot/dts/kirkwood-iconnect.dts            |   15 ++++++
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |   22 ++++++++
 arch/arm/boot/dts/kirkwood-is2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |   15 ++++++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi               |   26 ++++++++++
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |   25 +++++++++
 .../boot/dts/kirkwood-netgear_readynas_duo_v2.dts  |   15 ++++++
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |   15 ++++++
 arch/arm/boot/dts/kirkwood-ns2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-ns2lite.dts             |    2 +
 arch/arm/boot/dts/kirkwood-ns2max.dts              |    2 +
 arch/arm/boot/dts/kirkwood-ns2mini.dts             |    2 +
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |   15 ++++++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   15 ++++++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   15 ++++++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 ++++++++++++++++++++
 25 files changed, 373 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/kirkwood-cloudbox.dts b/arch/arm/boot/dts/kirkwood-cloudbox.dts
index 5f21d4e..d4f1e89 100644
--- a/arch/arm/boot/dts/kirkwood-cloudbox.dts
+++ b/arch/arm/boot/dts/kirkwood-cloudbox.dts
@@ -87,3 +87,18 @@
 		gpios = <&gpio0 17 0>;
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dnskw.dtsi b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
index 6875ac0..b203f07 100644
--- a/arch/arm/boot/dts/kirkwood-dnskw.dtsi
+++ b/arch/arm/boot/dts/kirkwood-dnskw.dtsi
@@ -217,3 +217,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dockstar.dts b/arch/arm/boot/dts/kirkwood-dockstar.dts
index 0196cf6..1b46882 100644
--- a/arch/arm/boot/dts/kirkwood-dockstar.dts
+++ b/arch/arm/boot/dts/kirkwood-dockstar.dts
@@ -91,3 +91,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-dreamplug.dts b/arch/arm/boot/dts/kirkwood-dreamplug.dts
index 289e51d..3ce258b 100644
--- a/arch/arm/boot/dts/kirkwood-dreamplug.dts
+++ b/arch/arm/boot/dts/kirkwood-dreamplug.dts
@@ -99,3 +99,29 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&eth1 { status = "okay"; };
+&egiga1 {
+	status = "okay";
+	phy = <&ethphy1>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		reg = <1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-goflexnet.dts b/arch/arm/boot/dts/kirkwood-goflexnet.dts
index c3573be..84fe313 100644
--- a/arch/arm/boot/dts/kirkwood-goflexnet.dts
+++ b/arch/arm/boot/dts/kirkwood-goflexnet.dts
@@ -170,3 +170,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts b/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
index 44fd97d..894e658 100644
--- a/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
+++ b/arch/arm/boot/dts/kirkwood-guruplug-server-plus.dts
@@ -96,3 +96,29 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&eth1 { status = "okay"; };
+&egiga1 {
+	status = "okay";
+	phy = <&ethphy1>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		reg = <1>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ib62x0.dts b/arch/arm/boot/dts/kirkwood-ib62x0.dts
index 5335b1a..7e7845d 100644
--- a/arch/arm/boot/dts/kirkwood-ib62x0.dts
+++ b/arch/arm/boot/dts/kirkwood-ib62x0.dts
@@ -119,3 +119,18 @@
 
 
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-iconnect.dts b/arch/arm/boot/dts/kirkwood-iconnect.dts
index 12ccf74..7991168 100644
--- a/arch/arm/boot/dts/kirkwood-iconnect.dts
+++ b/arch/arm/boot/dts/kirkwood-iconnect.dts
@@ -168,3 +168,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@11 {
+		device_type = "ethernet-phy";
+		reg = <11>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts b/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
index 3694e94..40e85aa 100644
--- a/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
+++ b/arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts
@@ -191,3 +191,25 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	speed = <1000>;
+	duplex = <1>;
+};
+
+&eth1 { status = "okay"; };
+&egiga1 {
+	status = "okay";
+	phy = <&ethphy1>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy1: ethernet-phy@11 {
+		device_type = "ethernet-phy";
+		reg = <11>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-is2.dts b/arch/arm/boot/dts/kirkwood-is2.dts
index 0bdce0a..2e5fe72 100644
--- a/arch/arm/boot/dts/kirkwood-is2.dts
+++ b/arch/arm/boot/dts/kirkwood-is2.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
index 5bbd054..fd97497 100644
--- a/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
+++ b/arch/arm/boot/dts/kirkwood-km_kirkwood.dts
@@ -43,3 +43,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-lsxl.dtsi b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
index 37d45c4..e9d61db 100644
--- a/arch/arm/boot/dts/kirkwood-lsxl.dtsi
+++ b/arch/arm/boot/dts/kirkwood-lsxl.dtsi
@@ -201,3 +201,29 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&eth1 { status = "okay"; };
+&egiga1 {
+	status = "okay";
+	phy = <&ethphy1>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+
+	ethphy1: ethernet-phy@8 {
+		device_type = "ethernet-phy";
+		reg = <8>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-mplcec4.dts b/arch/arm/boot/dts/kirkwood-mplcec4.dts
index 7588241..326cc48 100644
--- a/arch/arm/boot/dts/kirkwood-mplcec4.dts
+++ b/arch/arm/boot/dts/kirkwood-mplcec4.dts
@@ -182,3 +182,28 @@
 	};
 };
 
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&eth1 { status = "okay"; };
+&egiga1 {
+	status = "okay";
+	phy = <&ethphy1>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@1 {
+		device_type = "ethernet-phy";
+		reg = <1>;
+	};
+
+	ethphy1: ethernet-phy@2 {
+		device_type = "ethernet-phy";
+		reg = <2>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts b/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
index 1ca66ab..f3b39f7 100644
--- a/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
+++ b/arch/arm/boot/dts/kirkwood-netgear_readynas_duo_v2.dts
@@ -178,3 +178,18 @@
                 };
         };
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ns2-common.dtsi b/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
index 6affd92..b205832 100644
--- a/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ns2-common.dtsi
@@ -82,3 +82,18 @@
 	};
 
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy {
+		device_type = "ethernet-phy";
+                /* overwrite reg property in board file */
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ns2.dts b/arch/arm/boot/dts/kirkwood-ns2.dts
index f2d36ecf..8ffd552 100644
--- a/arch/arm/boot/dts/kirkwood-ns2.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2lite.dts b/arch/arm/boot/dts/kirkwood-ns2lite.dts
index b02eb4e..16332f8 100644
--- a/arch/arm/boot/dts/kirkwood-ns2lite.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2lite.dts
@@ -28,3 +28,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2max.dts b/arch/arm/boot/dts/kirkwood-ns2max.dts
index bcec4d6..68d767d 100644
--- a/arch/arm/boot/dts/kirkwood-ns2max.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2max.dts
@@ -47,3 +47,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ns2mini.dts b/arch/arm/boot/dts/kirkwood-ns2mini.dts
index adab1ab..5b1b17b 100644
--- a/arch/arm/boot/dts/kirkwood-ns2mini.dts
+++ b/arch/arm/boot/dts/kirkwood-ns2mini.dts
@@ -48,3 +48,5 @@
 		};
 	};
 };
+
+&ethphy0 { reg = <0>; };
diff --git a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
index d27f724..d8109f9 100644
--- a/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
+++ b/arch/arm/boot/dts/kirkwood-openblocks_a6.dts
@@ -210,3 +210,18 @@
 		};
         };
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-topkick.dts b/arch/arm/boot/dts/kirkwood-topkick.dts
index 66eb45b..dc3bb78 100644
--- a/arch/arm/boot/dts/kirkwood-topkick.dts
+++ b/arch/arm/boot/dts/kirkwood-topkick.dts
@@ -201,3 +201,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy@0 {
+		device_type = "ethernet-phy";
+		reg = <0>;
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6281.dts b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
index 8295c83..0bd67bf 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6281.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6281.dts
@@ -49,4 +49,6 @@
 			gpios = <&gpio0 16 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219-6282.dts b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
index df3f95d..a1bdef6 100644
--- a/arch/arm/boot/dts/kirkwood-ts219-6282.dts
+++ b/arch/arm/boot/dts/kirkwood-ts219-6282.dts
@@ -49,4 +49,6 @@
 			gpios = <&gpio1 5 1>;
 		};
 	};
-};
\ No newline at end of file
+};
+
+&ethphy0 { reg = <8>; };
diff --git a/arch/arm/boot/dts/kirkwood-ts219.dtsi b/arch/arm/boot/dts/kirkwood-ts219.dtsi
index 64ea27c..5865dc5 100644
--- a/arch/arm/boot/dts/kirkwood-ts219.dtsi
+++ b/arch/arm/boot/dts/kirkwood-ts219.dtsi
@@ -76,3 +76,18 @@
 		};
 	};
 };
+
+&eth0 { status = "okay"; };
+&egiga0 {
+	status = "okay";
+	phy = <&ethphy0>;
+};
+
+&mdio {
+	status = "okay";
+
+	ethphy0: ethernet-phy {
+		device_type = "ethernet-phy";
+                /* overwrite reg property in board file */
+	};
+};
diff --git a/arch/arm/boot/dts/kirkwood.dtsi b/arch/arm/boot/dts/kirkwood.dtsi
index fada7e6..c01a273 100644
--- a/arch/arm/boot/dts/kirkwood.dtsi
+++ b/arch/arm/boot/dts/kirkwood.dtsi
@@ -202,5 +202,57 @@
 			clocks = <&gate_clk 4>;
 			status = "disabled";
 		};
+
+		mdio: mdio-bus@72004 {
+			compatible = "marvell,orion-mdio";
+			reg = <0x72004 0x84>;
+			interrupts = <11>;
+			clocks = <&gate_clk 0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			status = "disabled";
+
+			/* add phy nodes in board file */
+		};
+
+		eth0: ethernet-controller@72000 {
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x72000 0x4000>;
+			clocks = <&gate_clk 0>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga0: ethernet-port@0 {
+				compatible = "marvell,mv643xx-eth";
+				device_type = "network";
+				reg = <0>;
+				interrupts = <11>;
+				clocks = <&gate_clk 0>;
+				/* set phy property in board file */
+				status = "disabled";
+			};
+		};
+
+		eth1: ethernet-controller@76000 {
+			compatible = "marvell,mv643xx-eth-block";
+			reg = <0x76000 0x4000>;
+			clocks = <&gate_clk 19>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			tx-csum-limit = <1600>;
+			status = "disabled";
+
+			egiga1: ethernet-port@1 {
+				compatible = "marvell,mv643xx-eth";
+				device_type = "network";
+				reg = <1>;
+				interrupts = <15>;
+				clocks = <&gate_clk 19>;
+				/* set phy property in board file */
+				status = "disabled";
+			};
+		};
 	};
 };
-- 
1.7.2.5
