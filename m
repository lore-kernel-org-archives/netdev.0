From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: [PATCH] using mii-bitbang on different processor ports - update
	the booting-without-of.txt-file
Date: Tue, 06 Nov 2007 09:51:57 +0100
Message-ID: <1194339117.3467.8.camel@p60635-ste.ids.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:60606 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063AbXKFIv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 03:51:59 -0500
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id B408EF4910C
	for <netdev@vger.kernel.org>; Tue,  6 Nov 2007 09:51:57 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch updates the booting-without-of.txt-file.
There is a description for the case
if mdio data and clock pins are on different processor ports.
It is a extending for e-mail "[PATCH v3] using mii-bitbang on different processor ports".

Signed-off-by: Sergej Stepanov <Sergej.Stepanov@ids.de>
--

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index a96e853..497d8d8 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1956,6 +1956,12 @@ platforms are moved over to use the flattened-device-tree model.
 		fsl,mdc-pin = <13>;
 	};
 
+   The "reg"-property may have also depending on board design
+   the following form:
+	reg = <10d40 14 10d60 14>;
+   In that case the pin for mdio data controlling is on the port C,
+   and the pin for mdio clock controlling is on the port D.
+
    v) Baud Rate Generators
 
    Currently defined compatibles:

