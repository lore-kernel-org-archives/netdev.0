From: Patrick Ringl <patrick_@freenet.de>
Subject: [PATCH] fix typo in net/ieee80211/Kconfig
Date: Sat, 24 Mar 2007 23:56:58 +0100
Message-ID: <4605ACBA.6040902@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090604060306070800080007"
Cc: torvalds@linux-foundation.org, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout0.freenet.de ([194.97.50.131]:56194 "EHLO mout0.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932869AbXCXW5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Mar 2007 18:57:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090604060306070800080007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,
this is just a QA / cosmetic fix .. nevertheless the documentation about 
modules / drivers should be appropriate to the great work of those who 
write all the real important stuff. :-)

The following patch is against 2.6.21-rc4:


--- /root/dev/linux-2.6.20-o/net/ieee80211/Kconfig    2007-02-04 
19:44:54.000000000 +0100
+++ /root/dev/linux-2.6.20/net/ieee80211/Kconfig    2007-03-24 
23:43:22.000000000 +0100
@@ -38,7 +38,7 @@
     Include software based cipher suites in support of IEEE
     802.11's WEP.  This is needed for WEP as well as 802.1x.
 
-    This can be compiled as a modules and it will be called
+    This can be compiled as a module and it will be called
     "ieee80211_crypt_wep".
 
 config IEEE80211_CRYPT_CCMP
@@ -51,7 +51,7 @@
     (aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with CCMP enabled
     networks.
 
-    This can be compiled as a modules and it will be called
+    This can be compiled as a module and it will be called
     "ieee80211_crypt_ccmp".
 
 config IEEE80211_CRYPT_TKIP
@@ -66,7 +66,7 @@
     (aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled
     networks.
 
-    This can be compiled as a modules and it will be called
+    This can be compiled as a module and it will be called
     "ieee80211_crypt_tkip".
 
 source "net/ieee80211/softmac/Kconfig"

---

regards,
Patrick



--------------090604060306070800080007
Content-Type: text/plain;
 name="ieee80211_Kconfig_typo"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ieee80211_Kconfig_typo"

--- /root/dev/linux-2.6.20-o/net/ieee80211/Kconfig	2007-02-04 19:44:54.000000000 +0100
+++ /root/dev/linux-2.6.20/net/ieee80211/Kconfig	2007-03-24 23:43:22.000000000 +0100
@@ -38,7 +38,7 @@
 	Include software based cipher suites in support of IEEE
 	802.11's WEP.  This is needed for WEP as well as 802.1x.
 
-	This can be compiled as a modules and it will be called
+	This can be compiled as a module and it will be called
 	"ieee80211_crypt_wep".
 
 config IEEE80211_CRYPT_CCMP
@@ -51,7 +51,7 @@
 	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with CCMP enabled
 	networks.
 
-	This can be compiled as a modules and it will be called
+	This can be compiled as a module and it will be called
 	"ieee80211_crypt_ccmp".
 
 config IEEE80211_CRYPT_TKIP
@@ -66,7 +66,7 @@
 	(aka TGi, WPA, WPA2, WPA-PSK, etc.) for use with TKIP enabled
 	networks.
 
-	This can be compiled as a modules and it will be called
+	This can be compiled as a module and it will be called
 	"ieee80211_crypt_tkip".
 
 source "net/ieee80211/softmac/Kconfig"

--------------090604060306070800080007--
