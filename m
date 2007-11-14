From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: [PATCH v2] using mii-bitbang on different processor ports - update
	the booting-without-of.txt-file
Date: Wed, 14 Nov 2007 14:41:34 +0100
Message-ID: <1195047694.3334.4.camel@p60365-ste>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:47205 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754515AbXKNNmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 08:42:01 -0500
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id 0CD73F491B4
	for <netdev@vger.kernel.org>; Wed, 14 Nov 2007 14:41:49 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch updates the booting-without-of.txt-file.
There is a description for the case
if mdio data and clock pins are on different processor ports.
It extends the "[PATCH v3] using mii-bitbang on different processor ports".

Signed-off-by: Sergej Stepanov <Sergej.Stepanov@ids.de>
Signed-off-by: Scott Wood <scottwood@freescale.com>
--

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index 497d8d8..084d31b 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1936,11 +1936,15 @@ platforms are moved over to use the flattened-device-tree model.
 
    Currently defined compatibles:
    fsl,pq1-fec-mdio (reg is same as first resource of FEC device)
-   fsl,cpm2-mdio-bitbang (reg is port C registers)
+   fsl,cpm2-mdio-bitbang
 
    Properties for fsl,cpm2-mdio-bitbang:
-   fsl,mdio-pin : pin of port C controlling mdio data
-   fsl,mdc-pin : pin of port C controlling mdio clock
+   The first reg resource is the I/O port register block on which MDIO
+   resides.  The second reg resource is the I/O port register block on
+   which MDC resides.  If there is only one reg resource, it is used for
+   both MDIO and MDC.
+   fsl,mdio-pin : pin of chosen port for controlling mdio data
+   fsl,mdc-pin : pin of chosen port for controlling mdio clock
 
    Example:

