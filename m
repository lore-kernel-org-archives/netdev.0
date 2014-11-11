From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 1/9] dt/bindings: fix documentation of ethernet-phy compatible property
Date: Tue, 11 Nov 2014 20:00:07 +0100
Message-ID: <1415732415-10363-2-git-send-email-johan@kernel.org>
References: <1415732415-10363-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>, devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:39252 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbaKKTAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 14:00:44 -0500
In-Reply-To: <1415732415-10363-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent commit extended the documentation of the ethernet-phy
compatible property, but placed the new paragraph under the max-speed
property.

Fixes: f00e756ed12d ("dt: Document a compatible entry for MDIO ethernet
Phys")
Cc: devicetree@vger.kernel.org
Signed-off-by: Johan Hovold <johan@kernel.org>
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
