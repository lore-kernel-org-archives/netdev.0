From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH 2/5] devicetree: bindings: Properly document micrel ks8851 SPI
 chips
Date: Thu, 22 May 2014 14:00:10 -0700
Message-ID: <1400792413-21618-3-git-send-email-sboyd@codeaurora.org>
References: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Nishanth Menon <nm@ti.com>, Mark Rutland <mark.rutland@arm.com>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
 linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1400792413-21618-1-git-send-email-sboyd@codeaurora.org>
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

The ks8851 SPI ethernet wasn't documented, but we documented the
optional regulator supply for it under the mll based ethernet
chip. Furthermore, that compatible string needed another 'l'. Fix
all of this and document the newly added optional vdd-io and
reset-gpios properties.

Cc: Nishanth Menon <nm@ti.com>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Pawel Moll <pawel.moll@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Ian Campbell <ijc+devicetree@hellion.org.uk>
Cc: Kumar Gala <galak@codeaurora.org>
Cc: <devicetree@vger.kernel.org>
Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 Documentation/devicetree/bindings/net/micrel-ks8851.txt | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel-ks8851.txt b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
index d54d0cc79487..bbdf9a7359a2 100644
--- a/Documentation/devicetree/bindings/net/micrel-ks8851.txt
+++ b/Documentation/devicetree/bindings/net/micrel-ks8851.txt
@@ -1,9 +1,18 @@
-Micrel KS8851 Ethernet mac
+Micrel KS8851 Ethernet mac (MLL)
 
 Required properties:
-- compatible = "micrel,ks8851-ml" of parallel interface
+- compatible = "micrel,ks8851-mll" of parallel interface
 - reg : 2 physical address and size of registers for data and command
 - interrupts : interrupt connection
 
+Micrel KS8851 Ethernet mac (SPI)
+
+Required properties:
+- compatible = "micrel,ks8851" or the deprecated "ks8851"
+- reg : chip select number
+- interrupts : interrupt connection
+
 Optional properties:
-- vdd-supply:	supply for Ethernet mac
+- vdd-supply: analog 3.3V supply for Ethernet mac
+- vdd-io-supply: digital 1.8V IO supply for Ethernet mac
+- reset-gpios: reset_n input pin
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation
