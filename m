From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Tue, 1 Mar 2016 10:16:22 -0700
Message-ID: <56D5CE66.3010602@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>
To: Bernhard Walle <bernhard@bwalle.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34718 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbcCARQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 12:16:24 -0500
Received: by mail-pa0-f45.google.com with SMTP id fy10so115280308pac.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 09:16:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We need that for a custom hardware that needs the reverse reset
sequence.

Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
---
 Documentation/devicetree/bindings/net/fsl-fec.txt | 3 +++
 drivers/net/ethernet/freescale/fec_main.c         | 8 ++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)
diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt
b/Documentation/devicetree/bindings/net/fsl-fec.txt
index a9eb611..a4799ff 100644
--- a/Documentation/devicetree/bindings/net/fsl-fec.txt
+++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
@@ -12,6 +12,9 @@ Optional properties:
   only if property "phy-reset-gpios" is available.  Missing the property
   will have the duration be 1 millisecond.  Numbers greater than 1000 are
   invalid and 1 millisecond will be used instead.
+- phy-reset-active-low : If present then the reset sequence using the GPIO
+  specified in the "phy-reset-gpios" property is reversed (H=reset state,
+  L=operation state).
____________________________


Shouldn't this be named phy-reset-active-high, as you are making the reset active high
H=reset, L= normal operation

Troy
