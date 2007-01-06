From: Gertjan van Wingerde <gwingerde@kpnplanet.nl>
Subject: [PATCH] d80211: Select CRYPTO_ECB when enabler d80211.
Date: Sat, 06 Jan 2007 18:00:50 +0100
Message-ID: <459FD5C2.6070007@kpnplanet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from CPEXFE-VOIP06.KPNplanet.nl ([194.151.105.224]:33084 "EHLO
	cpexfe-voip06.KPNplanet.nl" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbXAFRPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jan 2007 12:15:49 -0500
To: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The d80211 stack uses ECB mode block ciphers for the WEP implementation.
Make sure that support for CRYPTO_ECB is in the kernel when the d80211
stack is enabled (just like the other crypto algorithms).

Signed-off-by: Gertjan van Wingerde <gwingerde@kpnplanet.nl>

---
diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index 0f07d41..a6f2ba5 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -1,6 +1,7 @@
 config D80211
 	tristate "Generic IEEE 802.11 Networking Stack (dscape)"
 	select CRYPTO
+	select CRYPTO_ECB
 	select CRYPTO_ARC4
 	select CRYPTO_AES
 	---help---

