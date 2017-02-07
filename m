From: Lukasz Majewski <lukma@denx.de>
Subject: [PATCH v3 1/3] Documentation: devicetree: Add PHY no lane swap binding
Date: Tue,  7 Feb 2017 06:21:34 +0100
Message-ID: <1486444894-12841-1-git-send-email-lukma@denx.de>
Cc: linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Jon Mason <jon.mason@broadcom.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Lukasz Majewski <lukma@denx.de>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        jbrunet <jbrunet@baylibre.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the documentation to avoid PHY lane swapping. This is a boolean
entry to notify the phy device drivers that the TX/RX lanes NO need
to be swapped.
The use case for this binding mostly happens after wrong HW
configuration of PHY IC during bootstrap.

Signed-off-by: Lukasz Majewski <lukma@denx.de>

---
Changes for v3:
- Change binding to property
---
 Documentation/devicetree/bindings/net/phy.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index fb5056b..b558576 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -39,6 +39,10 @@ Optional Properties:
 - enet-phy-lane-swap: If set, indicates the PHY will swap the TX/RX lanes to
   compensate for the board being designed with the lanes swapped.
 
+- enet-phy-lane-no-swap: If set, indicates that PHY will disable swap of the
+  TX/RX lanes. This property allows the PHY to work correcly after e.g. wrong
+  bootstrap configuration caused by issues in PCB layout design.
+
 - eee-broken-100tx:
 - eee-broken-1000t:
 - eee-broken-10gt:
-- 
2.1.4
