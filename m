From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] ravb: add R8A7791 support
Date: Tue, 01 Dec 2015 01:01:18 +0300
Message-ID: <1661514.u50jDu7LON@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, devicetree@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35663 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895AbbK3WB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 17:01:27 -0500
Received: by lfdl133 with SMTP id l133so215087808lfd.2
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 14:01:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support  for yet another ARM member of the R-Car family, R-Car M2-W,
also known as R8A7791.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo but I wouldn't mind if it's
applied to 'net.git' instead. :-)

Changes in version 2:
- fixed the SoC name in the changelog.

 Documentation/devicetree/bindings/net/renesas,ravb.txt |    1 +
 drivers/net/ethernet/renesas/ravb_main.c               |    1 +
 2 files changed, 2 insertions(+)

Index: net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
===================================================================
--- net-next.orig/Documentation/devicetree/bindings/net/renesas,ravb.txt
+++ net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -5,6 +5,7 @@ interface contains.
 
 Required properties:
 - compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
+	      "renesas,etheravb-r8a7791" if the device is a part of R8A7791 SoC.
 	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
 	      "renesas,etheravb-r8a7795" if the device is a part of R8A7795 SoC.
 - reg: offset and length of (1) the register block and (2) the stream buffer.
Index: net-next/drivers/net/ethernet/renesas/ravb_main.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/ravb_main.c
+++ net-next/drivers/net/ethernet/renesas/ravb_main.c
@@ -1655,6 +1655,7 @@ static int ravb_mdio_release(struct ravb
 
 static const struct of_device_id ravb_match_table[] = {
 	{ .compatible = "renesas,etheravb-r8a7790", .data = (void *)RCAR_GEN2 },
+	{ .compatible = "renesas,etheravb-r8a7791", .data = (void *)RCAR_GEN2 },
 	{ .compatible = "renesas,etheravb-r8a7794", .data = (void *)RCAR_GEN2 },
 	{ .compatible = "renesas,etheravb-r8a7795", .data = (void *)RCAR_GEN3 },
 	{ }
