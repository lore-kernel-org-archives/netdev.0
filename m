From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 10/15] dsa: Add new optional devicetree property to describe EEPROM size
Date: Sun, 26 Oct 2014 09:52:40 -0700
Message-ID: <1414342365-27191-11-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>, devicetree@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Rob Herring <robh+dt@kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa core now supports reading from and writing to a switch EEPROM
if connected. Describe optional devicetree property indicating that
an EEPROM is present and its size.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- Added patch

 Documentation/devicetree/bindings/net/dsa/dsa.txt | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index a62c889..1ab828c 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -10,7 +10,11 @@ Required properties:
 - dsa,ethernet		: Should be a phandle to a valid Ethernet device node
 - dsa,mii-bus		: Should be a phandle to a valid MDIO bus device node
 
-Optionnal properties:
+Optional properties:
+- eeprom-length		: Set to the length of an EEPROM connected to the
+			  switch. Must be set if the switch can not detect
+			  the presence and/or size of a connected EEPROM,
+			  otherwise optional.
 - interrupts		: property with a value describing the switch
 			  interrupt number (not supported by the driver)
 
-- 
1.9.1
