From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 3/3] net: ethernet: mediatek: remove hwlro
 property in the device tree
Date: Thu, 6 Oct 2016 19:44:03 +0800
Message-ID: <1475754243-12557-4-git-send-email-nelson.chang@mediatek.com>
References: <1475754243-12557-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 nelsonch.tw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1475754243-12557-1-git-send-email-nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Since the proper way to check the hw lro capability is by the chip id,
hwlro property in the device tree should be removed.

Signed-off-by: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 Documentation/devicetree/bindings/net/mediatek-net.txt | 2 --
 1 file changed, 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/mediatek-net.txt b/Documentation/devicetree/bindings/net/mediatek-net.txt
index f095257..c010faf 100644
--- a/Documentation/devicetree/bindings/net/mediatek-net.txt
+++ b/Documentation/devicetree/bindings/net/mediatek-net.txt
@@ -24,7 +24,6 @@ Required properties:
 Optional properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
-- mediatek,hwlro: the capability if the hardware supports LRO functions
 
 * Ethernet MAC node
 
@@ -54,7 +53,6 @@ eth: ethernet@1b100000 {
 	reset-names = "eth";
 	mediatek,ethsys = <&ethsys>;
 	mediatek,pctl = <&syscfg_pctl_a>;
-	mediatek,hwlro;
 	#address-cells = <1>;
 	#size-cells = <0>;
 
-- 
1.9.1
