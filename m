From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/2] arm: dts: vf610-zii-dev-rev-b: remove ports label
Date: Fri,  6 Jan 2017 17:00:43 -0500
Message-ID: <20170106220043.21280-3-vivien.didelot@savoirfairelinux.com>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?= <uwe@kleine-koenig.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the "label" property is optional for Ethernet switch ports,
remove them in the ZII Dev Rev B board DTS.

On a Rev B board, once eth1 is up, this DTS now exposes to userspace:

    # ip link | grep ': ' | cut -d: -f2
     lo
     eth0
     eth1
     eth2@eth1
     eth3@eth1
     eth4@eth1
     eth5@eth1
     eth6@eth1
     eth7@eth1
     eth8@eth1
     eth9@eth1
     eth10@eth1
     eth11@eth1
     eth12@eth1

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 arch/arm/boot/dts/vf610-zii-dev-rev-b.dts | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
index 7ea617e47fe4..f9c8810aed7c 100644
--- a/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
+++ b/arch/arm/boot/dts/vf610-zii-dev-rev-b.dts
@@ -104,25 +104,21 @@
 					#size-cells = <0>;
 					port@0 {
 						reg = <0>;
-						label = "lan0";
 						phy-handle = <&switch0phy0>;
 					};
 
 					port@1 {
 						reg = <1>;
-						label = "lan1";
 						phy-handle = <&switch0phy1>;
 					};
 
 					port@2 {
 						reg = <2>;
-						label = "lan2";
 						phy-handle = <&switch0phy2>;
 					};
 
 					switch0port5: port@5 {
 						reg = <5>;
-						label = "dsa";
 						phy-mode = "rgmii-txid";
 						link = <&switch1port6
 							&switch2port9>;
@@ -134,7 +130,6 @@
 
 					port@6 {
 						reg = <6>;
-						label = "cpu";
 						ethernet = <&fec1>;
 						fixed-link {
 							speed = <100>;
@@ -186,25 +181,21 @@
 					#size-cells = <0>;
 					port@0 {
 						reg = <0>;
-						label = "lan3";
 						phy-handle = <&switch1phy0>;
 					};
 
 					port@1 {
 						reg = <1>;
-						label = "lan4";
 						phy-handle = <&switch1phy1>;
 					};
 
 					port@2 {
 						reg = <2>;
-						label = "lan5";
 						phy-handle = <&switch1phy2>;
 					};
 
 					switch1port5: port@5 {
 						reg = <5>;
-						label = "dsa";
 						link = <&switch2port9>;
 						phy-mode = "rgmii-txid";
 						fixed-link {
@@ -215,7 +206,6 @@
 
 					switch1port6: port@6 {
 						reg = <6>;
-						label = "dsa";
 						phy-mode = "rgmii-txid";
 						link = <&switch0port5>;
 						fixed-link {
@@ -263,22 +253,18 @@
 					#size-cells = <0>;
 					port@0 {
 						reg = <0>;
-						label = "lan6";
 					};
 
 					port@1 {
 						reg = <1>;
-						label = "lan7";
 					};
 
 					port@2 {
 						reg = <2>;
-						label = "lan8";
 					};
 
 					port@3 {
 						reg = <3>;
-						label = "optical3";
 						fixed-link {
 							speed = <1000>;
 							full-duplex;
@@ -289,7 +275,6 @@
 
 					port@4 {
 						reg = <4>;
-						label = "optical4";
 						fixed-link {
 							speed = <1000>;
 							full-duplex;
@@ -300,7 +285,6 @@
 
 					switch2port9: port@9 {
 						reg = <9>;
-						label = "dsa";
 						phy-mode = "rgmii-txid";
 						link = <&switch1port5
 							&switch0port5>;
-- 
2.11.0
