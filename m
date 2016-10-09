From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v2 3/3] net: smsc91x: add u16 workaround for pxa platforms
Date: Sun,  9 Oct 2016 22:33:47 +0200
Message-ID: <1476045227-2970-3-git-send-email-robert.jarzmik@free.fr>
References: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>,
        Jeremy Linton <jeremy.linton@arm.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476045227-2970-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
which must be aligned on 32 bits addresses.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Jeremy Linton <jeremy.linton@arm.com>
---
Since v1: rename dt property to pxa-u16-align4
      	  change the binding documentation file
---
 Documentation/devicetree/bindings/net/smsc-lan91c111.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
index e77e167593db..309e37eb7c7c 100644
--- a/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
+++ b/Documentation/devicetree/bindings/net/smsc-lan91c111.txt
@@ -13,3 +13,5 @@ Optional properties:
   16-bit access only.
 - power-gpios: GPIO to control the PWRDWN pin
 - reset-gpios: GPIO to control the RESET pin
+- pxa-u16-align4 : Boolean, put in place the workaround the force all
+		   u16 writes to be 32 bits aligned
-- 
2.1.4
