From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon,  3 Oct 2016 11:05:53 +0200
Message-ID: <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Robert Jarzmik <robert.jarzmik@free.fr>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
which must be aligned on 32 bits addresses.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 Documentation/devicetree/bindings/net/smsc911x.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
index 3fed3c124411..224965b7453c 100644
--- a/Documentation/devicetree/bindings/net/smsc911x.txt
+++ b/Documentation/devicetree/bindings/net/smsc911x.txt
@@ -13,6 +13,8 @@ Optional properties:
 - reg-io-width : Specify the size (in bytes) of the IO accesses that
   should be performed on the device.  Valid value for SMSC LAN is
   2 or 4.  If it's omitted or invalid, the size would be 2.
+- reg-u16-align4 : Boolean, put in place the workaround the force all
+  		   u16 writes to be 32 bits aligned
 - smsc,irq-active-high : Indicates the IRQ polarity is active-high
 - smsc,irq-push-pull : Indicates the IRQ type is push-pull
 - smsc,force-internal-phy : Forces SMSC LAN controller to use
-- 
2.1.4
