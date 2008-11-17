From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] phylib: fix phy name example in documentation
Date: Mon, 17 Nov 2008 16:03:13 +0200
Message-ID: <20081117140313.8019.48296.stgit@Programuotojas.82-135-208-232.ip.zebra.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:58856 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751331AbYKQODX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 09:03:23 -0500
Received: from 82-135-208-232.static.zebra.lt (HELO Programuotojas.82-135-208-232.ip.zebra.lt) (paulius.zaleckas@[82.135.208.232])
          (envelope-sender <paulius.zaleckas@teltonika.lt>)
          by teltonika.lt (qmail-ldap-1.03) with SMTP
          for <netdev@vger.kernel.org>; 17 Nov 2008 14:00:53 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All MDIO bus drivers currently name bus with "%x" format.
There is one exception where mv643xx_eth driver is using "%d".
Phy address on the bus uses format "%02x".

Fixing phy name example to match all real life MDIO drivers.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 Documentation/networking/phy.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 8df6a7b..88bb71b 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -96,7 +96,7 @@ Letting the PHY Abstraction Layer do Everything
    static void adjust_link(struct net_device *dev);
  
  Next, you need to know the device name of the PHY connected to this device. 
- The name will look something like, "phy0:0", where the first number is the
+ The name will look something like, "0:00", where the first number is the
  bus id, and the second is the PHY's address on that bus.  Typically,
  the bus is responsible for making its ID unique.
  

