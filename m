From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v3 4/4] net: mvneta: update clocks property and document
 additional clock-names
Date: Wed, 20 Jan 2016 19:27:25 +0800
Message-ID: <1453289245-2061-5-git-send-email-jszhang@marvell.com>
References: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, devicetree@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
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

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index aeea50c..d0cb869 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -6,12 +6,17 @@ Required properties:
 - interrupts: interrupt for the device
 - phy: See ethernet.txt file in the same directory.
 - phy-mode: See ethernet.txt file in the same directory
-- clocks: a pointer to the reference clock for this device.
+- clocks: List of clocks for this device. At least one clock is
+  mandatory for the core clock. If several clocks are given, then the
+  clock-names property must be used to identify them.
 
 Optional properties:
 - tx-csum-limit: maximum mtu supported by port that allow TX checksum.
   Value is presented in bytes. If not used, by default 1600B is set for
   "marvell,armada-370-neta" and 9800B for others.
+- clock-names: List of names corresponding to clocks property; shall be
+  "core" for core clock and "bus" for the optional bus clock.
+
 
 Example:
 
-- 
2.7.0.rc3
