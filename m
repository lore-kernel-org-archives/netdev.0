From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v5 2/7] Documentation: devicetree: add PHY lane swap binding
Date: Wed,  2 Nov 2016 13:08:03 -0400
Message-ID: <1478106488-11779-3-git-send-email-jon.mason@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the documentation for PHY lane swapping.  This is a boolean entry to
notify the phy device drivers that the TX/RX lanes need to be swapped.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
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
