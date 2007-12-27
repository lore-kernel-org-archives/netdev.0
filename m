From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6.25] CAN: Add missing Kbuild entries
Date: Thu, 27 Dec 2007 21:14:53 +0100
Message-ID: <477407BD.1040406@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000304090400080703000909"
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p07-fb.rzone.de ([81.169.146.215]:32355 "EHLO
	cg-p07-fb.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbXL0UP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2007 15:15:59 -0500
Received: from mo-p00-ob.rzone.de (klopstock-mo-p00-ob.mail [192.168.63.66])
	by charnel-fb-06.store (RZmta 14.0) with ESMTP id P00206jBRDeiMZ
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 21:15:58 +0100 (MET)
	(envelope-from: <oliver@hartkopp.net>)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000304090400080703000909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds the missing Kbuild entries and the missing Kbuild file 
in include/linux/can for the CAN subsystem.

It applies on the current net-2.6.25 tree.

Tnx & best regards,
Oliver

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Acked-by: Sam Ravnborg <sam@ravnborg.org>
---


--------------000304090400080703000909
Content-Type: text/x-diff;
 name="Kbuild-CAN.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="Kbuild-CAN.patch"

diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/can/Kbuild export/net2625-2007-12-27/include/linux/can/Kbuild
--- net-2.6.25/include/linux/can/Kbuild	1970-01-01 01:00:00.000000000 +0100
+++ export/net2625-2007-12-27/include/linux/can/Kbuild	2007-12-27 20:35:22.000000000 +0100
@@ -0,0 +1,3 @@
+header-y += raw.h
+header-y += bcm.h
+header-y += error.h
diff -uprN -X net-2.6.25/Documentation/dontdiff net-2.6.25/include/linux/Kbuild export/net2625-2007-12-27/include/linux/Kbuild
--- net-2.6.25/include/linux/Kbuild	2007-12-15 19:33:20.000000000 +0100
+++ export/net2625-2007-12-27/include/linux/Kbuild	2007-12-27 20:35:22.000000000 +0100
@@ -1,4 +1,5 @@
 header-y += byteorder/
+header-y += can/
 header-y += dvb/
 header-y += hdlc/
 header-y += isdn/
@@ -41,6 +42,7 @@ header-y += baycom.h
 header-y += bfs_fs.h
 header-y += blkpg.h
 header-y += bpqether.h
+header-y += can.h
 header-y += cdk.h
 header-y += chio.h
 header-y += coda_psdev.h

--------------000304090400080703000909--
