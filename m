From: Eric Anholt <eric@anholt.net>
Subject: [PATCH v2 1/2] net: dsa: b53: Add compatible strings for the
 Cygnus-family BCM11360.
Date: Tue, 25 Apr 2017 16:53:56 -0700
Message-ID: <20170425235357.7690-1-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Scott Branden <sbranden@broadcom.com>, Jon Mason <jonmason@broadcom.com>,
 Ray Jui <rjui@broadcom.com>, linux-kernel@vger.kernel.org,
 Eric Anholt <eric@anholt.net>, bcm-kernel-feedback-list@broadcom.com,
 linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 devicetree@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

Cygnus is a small family of SoCs, of which we currently have
devicetree for BCM11360 and BCM58300.  The 11360's B53 is mostly the
same as 58xx, just requiring a tiny bit of setup that was previously
missing.

Signed-off-by: Eric Anholt <eric@anholt.net>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---

v2: Reorder the entry in the docs (suggestion by Scott Branden), add
    missing '"'

 Documentation/devicetree/bindings/net/dsa/b53.txt | 3 +++
 drivers/net/dsa/b53/b53_srab.c                    | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/dsa/b53.txt b/Documentation/devicetree/bindings/net/dsa/b53.txt
index d6c6e41648d4..eb679e92d525 100644
--- a/Documentation/devicetree/bindings/net/dsa/b53.txt
+++ b/Documentation/devicetree/bindings/net/dsa/b53.txt
@@ -13,6 +13,9 @@ Required properties:
       "brcm,bcm5397"
       "brcm,bcm5398"
 
+  For the BCM11360 SoC, must be:
+      "brcm,bcm11360-srab" and the mandatory "brcm,cygnus-srab" string
+
   For the BCM5310x SoCs with an integrated switch, must be one of:
       "brcm,bcm53010-srab"
       "brcm,bcm53011-srab"
diff --git a/drivers/net/dsa/b53/b53_srab.c b/drivers/net/dsa/b53/b53_srab.c
index 8a62b6a69703..c37ffd1b6833 100644
--- a/drivers/net/dsa/b53/b53_srab.c
+++ b/drivers/net/dsa/b53/b53_srab.c
@@ -364,6 +364,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm53018-srab" },
 	{ .compatible = "brcm,bcm53019-srab" },
 	{ .compatible = "brcm,bcm5301x-srab" },
+	{ .compatible = "brcm,bcm11360-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58522-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58525-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58535-srab", .data = (void *)BCM58XX_DEVICE_ID },
@@ -371,6 +372,7 @@ static const struct of_device_id b53_srab_of_match[] = {
 	{ .compatible = "brcm,bcm58623-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm58625-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,bcm88312-srab", .data = (void *)BCM58XX_DEVICE_ID },
+	{ .compatible = "brcm,cygnus-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ .compatible = "brcm,nsp-srab", .data = (void *)BCM58XX_DEVICE_ID },
 	{ /* sentinel */ },
 };
-- 
2.11.0
