From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 10/12] dt-bindings: net: document bcmgenet WoL interrupt
Date: Mon, 13 Mar 2017 17:41:40 -0700
Message-ID: <20170314004142.4746-11-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A third interrupt cell can be provided to optionally specify
the interrupt used for handling Wake on LAN events.

Typically the wake up handling uses a separate interrupt
controller, so the interrupts-extended property is used to
accommodate this.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 Documentation/devicetree/bindings/net/brcm,bcmgenet.txt | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
index 10587bdadbbe..01a70463cbc5 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcmgenet.txt
@@ -4,9 +4,12 @@ Required properties:
 - compatible: should contain one of "brcm,genet-v1", "brcm,genet-v2",
   "brcm,genet-v3", "brcm,genet-v4".
 - reg: address and length of the register set for the device
-- interrupts: must be two cells, the first cell is the general purpose
-  interrupt line, while the second cell is the interrupt for the ring
-  RX and TX queues operating in ring mode
+- interrupts and/or interrupts-extended: must be two cells, the first cell
+  is the general purpose interrupt line, while the second cell is the
+  interrupt for the ring RX and TX queues operating in ring mode.  An
+  optional third interrupt cell for Wake-on-LAN can be specified.
+  See Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
+  for information on the property specifics.
 - phy-mode: see ethernet.txt file in the same directory
 - #address-cells: should be 1
 - #size-cells: should be 1
-- 
2.11.1
