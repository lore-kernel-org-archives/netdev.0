From: Alexander Shiyan <shc_work@mail.ru>
Subject: [PATCH 2/2] dt: bindings: Add bindings for Cirrus Logic CS89x0 ethernet chip
Date: Mon, 13 Jun 2016 18:52:17 +0300
Message-ID: <1465833137-836-1-git-send-email-shc_work@mail.ru>
Cc: devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Alexander Shiyan <shc_work@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.179.22]:43854 "EHLO
	fallback2.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161143AbcFMQXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:23:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add device tree binding documentation details for Cirrus Logic
CS8900/CS8920 ethernet chip.

Signed-off-by: Alexander Shiyan <shc_work@mail.ru>
---
 Documentation/devicetree/bindings/net/cirrus,cs89x0.txt | 13 +++++++++++++
 1 file changed, 13 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/cirrus,cs89x0.txt

diff --git a/Documentation/devicetree/bindings/net/cirrus,cs89x0.txt b/Documentation/devicetree/bindings/net/cirrus,cs89x0.txt
new file mode 100644
index 0000000..c070076
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/cirrus,cs89x0.txt
@@ -0,0 +1,13 @@
+* Cirrus Logic CS8900/CS8920 Network Controller
+
+Required properties:
+- compatible	: Should be "cirrus,cs8900" or "cirrus,cs8920".
+- reg		: Address and length of the IO space.
+- interrupts	: Should contain the controller interrupt line.
+
+Examples:
+	eth0: eth@10000000 {
+		compatible = "cirrus,cs8900";
+		reg = <0x10000000 0x400>;
+		interrupts = <10>;
+	};
-- 
2.4.9
