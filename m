From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v3 3/6] dt: booting-without-of: DT fix s/#interrupt-cell/#interrupt-cells/
Date: Fri,  2 Jun 2017 14:38:46 +0200
Message-ID: <1496407129-13527-4-git-send-email-geert+renesas@glider.be>
References: <1496407129-13527-1-git-send-email-geert+renesas@glider.be>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        dri-devel@lists.freedesktop.org, linux-amlogic@lists.infradead.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: David Airlie <airlied@linux.ie>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Chanho Min <chanho.min@lge.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:34224 "EHLO
        baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751204AbdFBMjK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 08:39:10 -0400
In-Reply-To: <1496407129-13527-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
Acked-by: Rob Herring <robh@kernel.org>
---
v3:
  - No changes,

v2:
  - Add Acked-by.
---
 Documentation/devicetree/booting-without-of.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/devicetree/booting-without-of.txt b/Documentation/devicetree/booting-without-of.txt
index 280d283304bb82d8..f35d3adacb987f7d 100644
--- a/Documentation/devicetree/booting-without-of.txt
+++ b/Documentation/devicetree/booting-without-of.txt
@@ -1309,7 +1309,7 @@ number and level/sense information. All interrupt children in an
 OpenPIC interrupt domain use 2 cells per interrupt in their interrupts
 property.
 
-The PCI bus binding specifies a #interrupt-cell value of 1 to encode
+The PCI bus binding specifies a #interrupt-cells value of 1 to encode
 which interrupt pin (INTA,INTB,INTC,INTD) is used.
 
 2) interrupt-parent property
-- 
2.7.4
