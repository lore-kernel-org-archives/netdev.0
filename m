From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v3 4/4] net: smsc91x: add u16 workaround for pxa platforms
Date: Mon, 17 Oct 2016 21:45:32 +0200
Message-ID: <1476733532-29716-5-git-send-email-robert.jarzmik@free.fr>
References: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, linux-am33-list@redhat.com,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Jeremy Linton <jeremy.linton@arm.com>, linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 Daniel Mack <daniel@zonque.org>, Haojian Zhuang <haojian.zhuang@gmail.com>,
 Robert Jarzmik <robert.jarzmik@free.fr>,
 Jonathan Cameron <jic23@cam.ac.uk>, David Howells <dhowells@redhat.com>,
 Nicolas Pitre <nico@fluxnic.net>, "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1476733532-29716-1-git-send-email-robert.jarzmik@free.fr>
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
