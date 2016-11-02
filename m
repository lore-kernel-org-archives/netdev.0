From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v5 4/7] Documentation: devicetree: net: add NS2 bindings to
 amac
Date: Wed,  2 Nov 2016 13:08:05 -0400
Message-ID: <1478106488-11779-5-git-send-email-jon.mason@broadcom.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
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
In-Reply-To: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
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

Clean-up the documentation to the bgmac-amac driver, per suggestion by
Rob Herring, and add details for NS2 support.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 Documentation/devicetree/bindings/net/brcm,amac.txt | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
index ba5ecc1..2fefa1a 100644
--- a/Documentation/devicetree/bindings/net/brcm,amac.txt
+++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
@@ -2,11 +2,17 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
 -------------------------------------------------------------
 
 Required properties:
- - compatible:	"brcm,amac" or "brcm,nsp-amac"
- - reg:		Address and length of the GMAC registers,
-		Address and length of the GMAC IDM registers
- - reg-names:	Names of the registers.  Must have both "amac_base" and
-		"idm_base"
+ - compatible:	"brcm,amac"
+		"brcm,nsp-amac"
+		"brcm,ns2-amac"
+ - reg:		Address and length of the register set for the device. It
+		contains the information of registers in the same order as
+		described by reg-names
+ - reg-names:	Names of the registers.
+		"amac_base":	Address and length of the GMAC registers
+		"idm_base":	Address and length of the GMAC IDM registers
+		"nicpm_base":	Address and length of the NIC Port Manager
+				registers (required for Northstar2)
  - interrupts:	Interrupt number
 
 Optional properties:
-- 
2.7.4
