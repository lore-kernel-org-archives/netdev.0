From: Keyur Chudgar <kchudgar@apm.com>
Subject: [PATCH v1 1/3] Documentation: dtb: Add port-id field for APM X-Gene
 ethernet
Date: Tue, 17 Mar 2015 11:27:11 -0700
Message-ID: <1426616833-9671-2-git-send-email-kchudgar@apm.com>
References: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Keyur Chudgar <kchudgar@apm.com>, patches@apm.com,
 linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
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

Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index 6151999..dc7961b 100644
--- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -15,6 +15,7 @@ Required properties for all the ethernet interfaces:
   - "ring_csr": Descriptor ring control and status register address space
   - "ring_cmd": Descriptor ring command register address space
 - interrupts: Ethernet main interrupt
+- port-id: Port number (0 or 1)
 - clocks: Reference to the clock entry.
 - local-mac-address: MAC address assigned to this device
 - phy-connection-type: Interface type between ethernet device and PHY device
@@ -49,6 +50,7 @@ Example:
 		      <0x0 0X10000000 0x0 0X200>;
 		reg-names = "enet_csr", "ring_csr", "ring_cmd";
 		interrupts = <0x0 0x3c 0x4>;
+		port-id = <0>;
 		clocks = <&menetclk 0>;
 		local-mac-address = [00 01 73 00 00 01];
 		phy-connection-type = "rgmii";
-- 
1.9.1
