From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v2 3/3] devicetree: add
	devicetree bindings for cc2520 driver
Date: Wed, 18 Jun 2014 10:46:05 +0530
Message-ID: <1403068565-32224-4-git-send-email-varkab@cdac.in>
References: <1403068565-32224-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1403068565-32224-1-git-send-email-varkab-If5XQcfNmg0@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

devicetree bindings for cc2520 radio driver.

Signed-off-by: Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>
---
 .../devicetree/bindings/net/ieee802154/cc2520.txt  |   26 ++++++++++++++++++++
 1 file changed, 26 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt

diff --git a/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
new file mode 100644
index 0000000..f0a749d
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
@@ -0,0 +1,26 @@
+CC2520 IEEE 802.15.4 Compatible Radio
+
+Required properties:
+	- compatible:		should be "ti,cc2520"
+	- spi-max-frequency:	maximal bus speed (8000000), should be set to 4000000 depends
+				sync or async operation mode
+	- reg:			the chipselect index
+	- mode:			SPI mode
+Example:
+
+	cc2520@0 {
+		compatible = "ti,cc2520";
+		reg = <0>;
+		spi-max-frequency = <4000000>;
+		mode = <1>;
+
+		pinctrl-names = "default";
+		pinctrl-0 = <&cc2520_cape_pins>;	/*GPIO pin muxing details*/
+
+		fifo-gpio = <&gpio1 18 0>;
+		fifop-gpio = <&gpio1 19 0>;
+		sfd-gpio = <&gpio1 13 0>;
+		cca-gpio = <&gpio1 16 0>;
+		vreg-gpio = <&gpio0 31 0>;
+		reset-gpio = <&gpio1 12 0>;
+	};
-- 
1.7.9.5


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
