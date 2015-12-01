From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH 2/2 net-next] ravb: Add device tree support for r8a779[123]
Date: Tue,  1 Dec 2015 16:43:03 +0900
Message-ID: <1448955783-22806-3-git-send-email-horms+renesas@verge.net.au>
References: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	devicetree@vger.kernel.org
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1448955783-22806-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simply document new compat strings.
As a previous patch adds a generic R-Car Gen2 compat string
there appears to be no need for a driver updates.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 Documentation/devicetree/bindings/net/renesas,ravb.txt | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
index 115006325bff..076accb652ad 100644
--- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -5,6 +5,9 @@ interface.
 
 Required properties:
 - compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
+	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
+	      "renesas,etheravb-r8a7792" if the device is a part of R8A7792 SoC.
+	      "renesas,etheravb-r8a7793" if the device is a part of R8A7793 SoC.
 	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
 	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
 	      "renesas,etheravb-gen2" for generic R-Car Gen 2 compatible interface.
-- 
2.1.4

