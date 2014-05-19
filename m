From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] Documentation: devicetree: add old and deprecated 'fixed-link'
Date: Mon, 19 May 2014 12:43:44 -0700
Message-ID: <1400528625-32744-4-git-send-email-f.fainelli@gmail.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:58560 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932648AbaESTpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 15:45:14 -0400
In-Reply-To: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the fixed-link Device Tree binding documentation to contain
information about the old and deprecated 5-digit 'fixed-link' property.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/devicetree/bindings/net/fixed-link.txt | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
index e956de1be935..a87e28b68dee 100644
--- a/Documentation/devicetree/bindings/net/fixed-link.txt
+++ b/Documentation/devicetree/bindings/net/fixed-link.txt
@@ -18,6 +18,13 @@ properties:
 * 'asym-pause' (boolean, optional), to indicate that asym_pause should
   be enabled.
 
+Old, deprecated 'fixed-link' binding:
+
+* 'fixed-link' : <a b c d e> where a is emulated phy id - choose any,
+  but unique to the all specified fixed-links, b is duplex - 0 half,
+  1 full, c is link speed - d#10/d#100/d#1000, d is pause - 0 no
+  pause, 1 pause, e is asym_pause - 0 no asym_pause, 1 asym_pause.
+
 Example:
 
 ethernet@0 {
-- 
1.9.1
