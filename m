From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v6 2/7] Documentation: devicetree: add PHY lane swap binding
Date: Fri,  4 Nov 2016 01:10:57 -0400
Message-ID: <1478236262-3351-3-git-send-email-jon.mason@broadcom.com>
References: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
 rafal@milecki.pl, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>, Rob Herring <robh+dt@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1478236262-3351-1-git-send-email-jon.mason@broadcom.com>
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

Add the documentation for PHY lane swapping.  This is a boolean entry to
notify the phy device drivers that the TX/RX lanes need to be swapped.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/phy.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index bc1c3c8..4627da3 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -35,6 +35,10 @@ Optional Properties:
 - broken-turn-around: If set, indicates the PHY device does not correctly
   release the turn around line low at the end of a MDIO transaction.
 
+- enet-phy-lane-swap: If set, indicates the PHY will swap the TX/RX lanes to
+  compensate for the board being designed with the lanes swapped.
+
+
 Example:
 
 ethernet-phy@0 {
-- 
2.7.4
