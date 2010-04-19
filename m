From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCHv2 7/7] X25: Update X25 interface documentation
Date: Tue, 20 Apr 2010 09:30:36 +1000
Message-ID: <1271719836.2802.89.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54257 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab0DSXal (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:30:41 -0400
Received: by pwj9 with SMTP id 9so3833988pwj.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:30:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 Documentation/networking/x25-iface.txt |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/x25-iface.txt b/Documentation/networking/x25-iface.txt
index 975cc87..78f662e 100644
--- a/Documentation/networking/x25-iface.txt
+++ b/Documentation/networking/x25-iface.txt
@@ -20,23 +20,23 @@ the rest of the skbuff, if any more information does exist.
 Packet Layer to Device Driver
 -----------------------------
 
-First Byte = 0x00
+First Byte = 0x00 (X25_IFACE_DATA)
 
 This indicates that the rest of the skbuff contains data to be transmitted
 over the LAPB link. The LAPB link should already exist before any data is
 passed down.
 
-First Byte = 0x01
+First Byte = 0x01 (X25_IFACE_CONNECT)
 
 Establish the LAPB link. If the link is already established then the connect
 confirmation message should be returned as soon as possible.
 
-First Byte = 0x02
+First Byte = 0x02 (X25_IFACE_DISCONNECT)
 
 Terminate the LAPB link. If it is already disconnected then the disconnect
 confirmation message should be returned as soon as possible.
 
-First Byte = 0x03
+First Byte = 0x03 (X25_IFACE_PARAMS)
 
 LAPB parameters. To be defined.
 
@@ -44,22 +44,22 @@ LAPB parameters. To be defined.
 Device Driver to Packet Layer
 -----------------------------
 
-First Byte = 0x00
+First Byte = 0x00 (X25_IFACE_DATA)
 
 This indicates that the rest of the skbuff contains data that has been
 received over the LAPB link.
 
-First Byte = 0x01
+First Byte = 0x01 (X25_IFACE_CONNECT)
 
 LAPB link has been established. The same message is used for both a LAPB
 link connect_confirmation and a connect_indication.
 
-First Byte = 0x02
+First Byte = 0x02 (X25_IFACE_DISCONNECT)
 
 LAPB link has been terminated. This same message is used for both a LAPB
 link disconnect_confirmation and a disconnect_indication.
 
-First Byte = 0x03
+First Byte = 0x03 (X25_IFACE_PARAMS)
 
 LAPB parameters. To be defined.
 
-- 
1.5.6.5



