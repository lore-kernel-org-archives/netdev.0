From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH 1/3] net/macb: Update DT bindings documentation
Date: Thu,  5 Mar 2015 17:27:20 +0100
Message-ID: <1425572842-6084-2-git-send-email-boris.brezillon@free-electrons.com>
References: <1425572842-6084-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Boris Brezillon <boris.brezillon@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425572842-6084-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add missing "cdns,at91sam9260-macb", "atmel,sama5d3-gem" and
"atmel,sama5d4-gem" compatible strings.

Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 Documentation/devicetree/bindings/net/macb.txt | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index aaa6964..ba19d67 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -2,10 +2,13 @@
 
 Required properties:
 - compatible: Should be "cdns,[<chip>-]{macb|gem}"
-  Use "cdns,at91sam9260-macb" Atmel at91sam9260 and at91sam9263 SoCs.
+  Use "cdns,at91sam9260-macb" for Atmel at91sam9 SoCs or the 10/100Mbit IP
+  available on sama5d3 SoCs.
   Use "cdns,at32ap7000-macb" for other 10/100 usage or use the generic form: "cdns,macb".
   Use "cdns,pc302-gem" for Picochip picoXcell pc302 and later devices based on
   the Cadence GEM, or the generic form: "cdns,gem".
+  Use "cdns,sama5d3-gem" for the Gigabit IP available on Atmel sama5d3 SoCs.
+  Use "cdns,sama5d4-gem" for the Gigabit IP available on Atmel sama5d4 SoCs.
 - reg: Address and length of the register set for the device
 - interrupts: Should contain macb interrupt
 - phy-mode: See ethernet.txt file in the same directory.
-- 
1.9.1
