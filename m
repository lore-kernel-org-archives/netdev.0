From: Jon Mason <jon.mason@broadcom.com>
Subject: [PATCH v2 3/6] Documentation: devicetree: net: add NS2 bindings to amac
Date: Fri, 28 Oct 2016 16:56:56 -0400
Message-ID: <1477688219-3871-4-git-send-email-jon.mason@broadcom.com>
References: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34111 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761943AbcJ1U5Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 16:57:16 -0400
Received: by mail-pf0-f177.google.com with SMTP id n85so42904271pfi.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 13:57:15 -0700 (PDT)
In-Reply-To: <1477688219-3871-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 Documentation/devicetree/bindings/net/brcm,amac.txt | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/brcm,amac.txt b/Documentation/devicetree/bindings/net/brcm,amac.txt
index ba5ecc1..f2b194e 100644
--- a/Documentation/devicetree/bindings/net/brcm,amac.txt
+++ b/Documentation/devicetree/bindings/net/brcm,amac.txt
@@ -2,11 +2,12 @@ Broadcom AMAC Ethernet Controller Device Tree Bindings
 -------------------------------------------------------------
 
 Required properties:
- - compatible:	"brcm,amac" or "brcm,nsp-amac"
+ - compatible:	"brcm,amac", "brcm,nsp-amac", or "brcm,ns2-amac"
  - reg:		Address and length of the GMAC registers,
 		Address and length of the GMAC IDM registers
+		Address and length of the NIC Port Manager registers (optional)
  - reg-names:	Names of the registers.  Must have both "amac_base" and
-		"idm_base"
+		"idm_base". "nicpm_base" is optional (required for NS2)
  - interrupts:	Interrupt number
 
 Optional properties:
-- 
2.7.4
