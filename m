From: <dinguyen@altera.com>
Subject: [PATCH 3/3] dts: stmmac: Document the clocks property in the stmmac base document
Date: Wed, 26 Mar 2014 22:45:12 -0500
Message-ID: <1395891912-26855-4-git-send-email-dinguyen@altera.com>
References: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <srinivas.kandagatla@st.com>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <arm@kernel.org>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<devicetree@vger.kernel.org>, Dinh Nguyen <dinguyen@altera.com>
To: <dinh.linux@gmail.com>, <arnd@arndb.de>, <davem@davemloft.net>,
	<peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:36111
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752984AbaC0DsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2014 23:48:07 -0400
In-Reply-To: <1395891912-26855-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dinh Nguyen <dinguyen@altera.com>

Add the clocks and clock-names property to the base stmmac dts bindings
document.

Signed-off-by: Dinh Nguyen <dinguyen@altera.com>
---
 Documentation/devicetree/bindings/net/stmmac.txt |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 94604e2..9897fa3 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -32,6 +32,10 @@ Optional properties:
 	reset phandle is given
 - max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
 			than the maximum frame size.
+- clocks: If present, the first clock should be the GMAC main clock,
+  further clocks may be specified in derived bindings.
+- clocks-names: One name for each entry in the clocks property, the
+  first one should be "stmmaceth".
 
 Examples:
 
@@ -44,4 +48,6 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		clocks = <&clock>;
+		clock-names = "stmmaceth">;
 	};
-- 
1.7.9.5
