From: Andrea Gelmini <andrea.gelmini@gelma.net>
Subject: [PATCH 058/199] Documentation/isdn/README.hfc-pci: Checkpatch cleanup
Date: Sun, 23 May 2010 21:50:22 +0200
Message-ID: <1274644226-23612-8-git-send-email-andrea.gelmini@gelma.net>
References: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Randy Dunlap <rdunlap@xenotime.net>, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
To: andrea.gelmini@gelma.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:9896 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190Ab0EWTuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 May 2010 15:50:51 -0400
In-Reply-To: <1274644226-23612-1-git-send-email-andrea.gelmini@gelma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation/isdn/README.hfc-pci:19: ERROR: trailing whitespace
Documentation/isdn/README.hfc-pci:25: ERROR: trailing whitespace
Documentation/isdn/README.hfc-pci:27: ERROR: trailing whitespace
Documentation/isdn/README.hfc-pci:32: ERROR: trailing whitespace
Documentation/isdn/README.hfc-pci:34: ERROR: trailing whitespace
Documentation/isdn/README.hfc-pci:36: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 Documentation/isdn/README.hfc-pci |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Documentation/isdn/README.hfc-pci b/Documentation/isdn/README.hfc-pci
index e8a4ef0..a61227f 100644
--- a/Documentation/isdn/README.hfc-pci
+++ b/Documentation/isdn/README.hfc-pci
@@ -16,24 +16,24 @@ And then:
 
 hisaxctrl <driver/cardname> 12 1
 
-This enables the echo mode. If Hex logging is activated the isdnctrlx 
+This enables the echo mode. If Hex logging is activated the isdnctrlx
 devices show a output with a line beginning of HEX: for the providers
 exchange and ECHO: for isdn devices sending to the provider.
 
 If more than one HFC-PCI cards are installed, a specific card may be selected
 at the hisax module load command line. Supply the load command with the desired
-IO-address of the desired card. 
+IO-address of the desired card.
 Example:
-There tree cards installed in your machine at IO-base addresses 0xd000, 0xd400 
+There tree cards installed in your machine at IO-base addresses 0xd000, 0xd400
 and 0xdc00
 If you want to use the card at 0xd400 standalone you should supply the insmod
 or depmod with type=35 io=0xd400.
 If you want to use all three cards, but the order needs to be at 0xdc00,0xd400,
-0xd000 you may give the parameters type=35,35,35 io=0xdc00,0xd400,0xd00 
+0xd000 you may give the parameters type=35,35,35 io=0xdc00,0xd400,0xd00
 Then the desired card will be the initialised in the desired order.
-If the io parameter is used the io addresses of all used cards should be 
+If the io parameter is used the io addresses of all used cards should be
 supplied else the parameter is assumed 0 and a auto search for a free card is
-invoked which may not give the wanted result. 
+invoked which may not give the wanted result.
 
 Comments and reports to werner@isdn4linux.de or werner@isdn-development.de
 
-- 
1.7.1.251.gf80a2

