From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/ieee80211/Kconfig: don't describe what gets selected
Date: Thu, 24 Feb 2005 22:42:24 +0100
Message-ID: <20050224214223.GJ8651@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@oss.sgi.com, jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The information what gets selected doesn't belong into the helh text 
(and at least "make menuconfig" already displays this information).

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.11-rc4-mm1-full/net/ieee80211/Kconfig.old	2005-02-24 22:31:07.000000000 +0100
+++ linux-2.6.11-rc4-mm1-full/net/ieee80211/Kconfig	2005-02-24 22:32:02.000000000 +0100
@@ -5,3 +5,3 @@
 	This option enables the hardware independent IEEE 802.11 
-	networking stack.  This option will also select NET_RADIO.
+	networking stack.
 
@@ -38,5 +38,3 @@
 	Include software based cipher suites in support of IEEE 
-	802.11's WEP.  This is needed for WEP as well as 802.1x.  This 
-	selects ARC4 under kernel crypto libraries, and CRC32 under 
-	kernel libraries. 
+	802.11's WEP.  This is needed for WEP as well as 802.1x.
 
@@ -52,4 +50,3 @@
 	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with CCMP enabled 
-	networks.  This selects AES support under kernel crypto 
-	libraries.
+	networks.
 
@@ -65,4 +62,3 @@
 	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled 
-	networks.  This selects Michael Mic support under kernel crypto 
-	libraries. 
+	networks.
 
