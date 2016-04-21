From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 5/6] Documentation: Binding doc for ethernet master in NS2
Date: Thu, 21 Apr 2016 14:48:42 +0530
Message-ID: <1461230323-27891-6-git-send-email-pramod.kumar@broadcom.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Suzuki K Poulose <suzuki.poulose@arm.com>, netdev@vger.kernel.org,
 Punit Agrawal <punit.agrawal@arm.com>, linux-kernel@vger.kernel.org,
 Pramod Kumar <pramod.kumar@broadcom.com>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh+dt@kernel.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
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

Adding binding doc for ethernet master present in shared
MDIO controller.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
---
 .../bindings/net/brcm,iproc-mdio-shared.txt        | 32 ++++++++++++++++++++++
 1 file changed, 32 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt

diff --git a/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
new file mode 100644
index 0000000..1ffdd4b
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/brcm,iproc-mdio-shared.txt
@@ -0,0 +1,32 @@
+Broadcom Ethernet master for shared mdio controller
+
+Required properties:
+- compatible: must be "brcm,iproc-mdio-master-eth"
+- reg: master id of Ethernet block
+- address-cells: should be 1
+- size-cells: should be 0
+
+Sub-nodes:
+  Each port's PHY should be represented as a sub-node.
+
+Sub-nodes required properties:
+- reg: the PHY number
+- phy-mode: media type connecting the PHY and MAC.
+
+
+Example:
+	eth-master@0 {
+		compatible = "brcm,iproc-mdio-master-eth";
+		reg = <0x0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		gphy0: eth-phy@10 {
+			reg = <0x10>;
+			phy-mode = "mii";
+		};
+		status = "ok"
+	};
+
+For more info on ethernet phy binding, please,refer to:
+Documentation/devicetree/bindings/net/phy.txt
+Documentation/devicetree/bindings/net/ethernet.txt
-- 
1.9.1
