From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 4/4] arm: mvebu: enable Ethernet controllers on Armada 370/XP
 eval boards
Date: Tue,  4 Sep 2012 15:06:44 +0200
Message-ID: <1346764004-16332-5-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Albert Stone <albert.stone@canonical.com>,
 Nadav Haklai <nadavh@marvell.com>, Ian Molton <ian.molton@codethink.co.uk>,
 David Marlin <dmarlin@redhat.com>, Rami Rosen <rosenr@marvell.com>,
 Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
To: "David S. Miller" <davem@davemloft.net>,
 Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch enables the two network interfaces of the Armada 370
official Marvell evaluation platform, and the four network interfaces
of the Armada XP official Marvell evaluation platform.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 arch/arm/boot/dts/armada-370-db.dts |   12 ++++++++++++
 arch/arm/boot/dts/armada-xp-db.dts  |   24 ++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/arch/arm/boot/dts/armada-370-db.dts b/arch/arm/boot/dts/armada-370-db.dts
index fffd5c2..890f253 100644
--- a/arch/arm/boot/dts/armada-370-db.dts
+++ b/arch/arm/boot/dts/armada-370-db.dts
@@ -38,5 +38,17 @@
 			clock-frequency = <600000000>;
 			status = "okay";
 		};
+                eth@d0070000 {
+                        clock-frequency = <200000000>;
+                        status = "okay";
+                        phy-mode = "rmii";
+                        phy-addr = <0>;
+                };
+                eth@d0074000 {
+                        clock-frequency = <200000000>;
+                        status = "okay";
+                        phy-mode = "rmii";
+                        phy-addr = <1>;
+                };
 	};
 };
diff --git a/arch/arm/boot/dts/armada-xp-db.dts b/arch/arm/boot/dts/armada-xp-db.dts
index f97040d..fd71b69 100644
--- a/arch/arm/boot/dts/armada-xp-db.dts
+++ b/arch/arm/boot/dts/armada-xp-db.dts
@@ -46,5 +46,29 @@
 			clock-frequency = <250000000>;
 			status = "okay";
 		};
+                eth@d0070000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "rmii";
+                        phy-addr = <0>;
+                };
+                eth@d0074000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "rmii";
+                        phy-addr = <1>;
+                };
+                eth@d0030000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "sgmii";
+                        phy-addr = <25>;
+                };
+                eth@d0034000 {
+                        clock-frequency = <250000000>;
+                        status = "okay";
+                        phy-mode = "sgmii";
+                        phy-addr = <27>;
+                };
 	};
 };
-- 
1.7.9.5
