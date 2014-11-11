From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/22] dt/bindings: fix documentation of ethernet-phy compatible property
Date: Tue, 11 Nov 2014 18:37:19 +0100
Message-ID: <1415727460-20417-2-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A recent commit extended the documentation of the ethernet-phy
compatible property, but placed the new paragraph under the max-speed
property.

Fixes: f00e756ed12d ("dt: Document a compatible entry for MDIO ethernet
Phys")

Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 Documentation/devicetree/bindings/net/phy.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 5b8c58903077..40831fbaff72 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -19,7 +19,6 @@ Optional Properties:
   specifications. If neither of these are specified, the default is to
   assume clause 22. The compatible list may also contain other
   elements.
-- max-speed: Maximum PHY supported speed (10, 100, 1000...)
 
   If the phy's identifier is known then the list may contain an entry
   of the form: "ethernet-phy-idAAAA.BBBB" where
@@ -29,6 +28,8 @@ Optional Properties:
             4 hex digits. This is the chip vendor OUI bits 19:24,
             followed by 10 bits of a vendor specific ID.
 
+- max-speed: Maximum PHY supported speed (10, 100, 1000...)
+
 Example:
 
 ethernet-phy@0 {
-- 
2.0.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
