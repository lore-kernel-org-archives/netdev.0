From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v4 3/4] dt: bindings: add ethernet phy eee-broken-modes option documentation
Date: Mon, 28 Nov 2016 16:50:27 +0100
Message-ID: <1480348229-25672-4-git-send-email-jbrunet@baylibre.com>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Yegor Yefremov <yegorslists@googlemail.com>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
Reviewed-by: Andreas Färber <afaerber@suse.de>
Tested-by: Neil Armstrong <narmstrong@baylibre.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 4627da3d52c4..54749b60a466 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -38,6 +38,8 @@ Optional Properties:
 - enet-phy-lane-swap: If set, indicates the PHY will swap the TX/RX lanes to
   compensate for the board being designed with the lanes swapped.
 
+- eee-broken-modes: Bits to clear in the MDIO_AN_EEE_ADV register to
+  disable EEE broken modes.
 
 Example:
 
-- 
2.7.4
