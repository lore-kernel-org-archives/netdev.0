From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] Documentation: networking: fix ASCII art in switchdev.txt
Date: Sat, 16 Sep 2017 13:10:06 -0700
Message-ID: <984d9d24-b558-6308-3252-1c8ddd5eb7c8@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Andreas Schwab <schwab@linux-m68k.org>,
        Jiri Pirko <jiri@resnulli.us>,
        Scott Feldman <sfeldma@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:57452 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdIPUKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 16 Sep 2017 16:10:14 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix ASCII art in Documentation/networking/switchdev.txt:

Change non-ASCII "spaces" to ASCII spaces.

Change 2 erroneous '+' characters in ASCII art to '-' (at the '*'
characters below):

line 32:
                     +--+----+----+----+-*--+----+---+  +-----+-----+
line 41:
                     +--------------+---*------------+

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 Documentation/networking/switchdev.txt |   64 +++++++++++------------
 1 file changed, 32 insertions(+), 32 deletions(-)

--- lnx-413.orig/Documentation/networking/switchdev.txt
+++ lnx-413/Documentation/networking/switchdev.txt
@@ -13,42 +13,42 @@ an example setup using a data-center-cla
 with SR-IOV or soft switches, such as OVS, are possible.
 
 
-                             User-space tools
+                             User-space tools
 
-       user space                   |
-      +-------------------------------------------------------------------+
-       kernel                       | Netlink
-                                    |
-                     +--------------+-------------------------------+
-                     |         Network stack                        |
-                     |           (Linux)                            |
-                     |                                              |
-                     +----------------------------------------------+
+       user space                   |
+      +-------------------------------------------------------------------+
+       kernel                       | Netlink
+                                    |
+                     +--------------+-------------------------------+
+                     |         Network stack                        |
+                     |           (Linux)                            |
+                     |                                              |
+                     +----------------------------------------------+
 
                            sw1p2     sw1p4     sw1p6
-                      sw1p1  +  sw1p3  +  sw1p5  +          eth1
-                        +    |    +    |    +    |            +
-                        |    |    |    |    |    |            |
-                     +--+----+----+----+-+--+----+---+  +-----+-----+
-                     |         Switch driver         |  |    mgmt   |
-                     |        (this document)        |  |   driver  |
-                     |                               |  |           |
-                     +--------------+----------------+  +-----------+
-                                    |
-       kernel                       | HW bus (eg PCI)
-      +-------------------------------------------------------------------+
-       hardware                     |
-                     +--------------+---+------------+
-                     |         Switch device (sw1)   |
-                     |  +----+                       +--------+
-                     |  |    v offloaded data path   | mgmt port
-                     |  |    |                       |
-                     +--|----|----+----+----+----+---+
-                        |    |    |    |    |    |
-                        +    +    +    +    +    +
-                       p1   p2   p3   p4   p5   p6
+                      sw1p1  +  sw1p3  +  sw1p5  +          eth1
+                        +    |    +    |    +    |            +
+                        |    |    |    |    |    |            |
+                     +--+----+----+----+----+----+---+  +-----+-----+
+                     |         Switch driver         |  |    mgmt   |
+                     |        (this document)        |  |   driver  |
+                     |                               |  |           |
+                     +--------------+----------------+  +-----------+
+                                    |
+       kernel                       | HW bus (eg PCI)
+      +-------------------------------------------------------------------+
+       hardware                     |
+                     +--------------+----------------+
+                     |         Switch device (sw1)   |
+                     |  +----+                       +--------+
+                     |  |    v offloaded data path   | mgmt port
+                     |  |    |                       |
+                     +--|----|----+----+----+----+---+
+                        |    |    |    |    |    |
+                        +    +    +    +    +    +
+                       p1   p2   p3   p4   p5   p6
 
-                             front-panel ports
+                             front-panel ports
 
 
                                     Fig 1.
