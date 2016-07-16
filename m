From: Jamie Lentin <jm@lentin.co.uk>
Subject: [PATCH v0 02/10] arm: orion5x: Add documentation for SoC and board
 bindings
Date: Sat, 16 Jul 2016 15:29:00 +0100
Message-ID: <1468679348-10522-3-git-send-email-jm@lentin.co.uk>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Jamie Lentin <jm@lentin.co.uk>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Imre Kaloz <kaloz@openwrt.org>, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
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

Copy the format for kirkwood/dove to orion5x

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 .../bindings/arm/marvell/marvell,orion5x.txt       | 23 ++++++++++++++++++++++
 1 file changed, 23 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt

diff --git a/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
new file mode 100644
index 0000000..a888011
--- /dev/null
+++ b/Documentation/devicetree/bindings/arm/marvell/marvell,orion5x.txt
@@ -0,0 +1,23 @@
+Marvell Orion SoC Family Device Tree Bindings
+---------------------------------------------
+
+Boards with a SoC of the Marvell Orion family, eg 88f5181
+
+* Required root node properties:
+compatible: must contain "marvell,orion5x"
+
+In addition, the above compatible shall be extended with the specific
+SoC. Currently known SoC compatibles are:
+
+"marvell,orion5x-88f5182"
+
+And in addition, the compatible shall be extended with the specific
+board. Currently known boards are:
+
+"buffalo,lsgl"
+"buffalo,lswsgl"
+"buffalo,lswtgl"
+"lacie,ethernet-disk-mini-v2"
+"lacie,d2-network"
+"marvell,rd-88f5182-nas"
+"maxtor,shared-storage-2"
-- 
2.8.1
