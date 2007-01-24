From: Marcus Better <marcus@better.se>
Subject: [PATCH] d80211: select CRC32 functions
Date: Wed, 24 Jan 2007 10:35:10 +0100
Message-ID: <ep798e$guu$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:45240 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750786AbXAXJfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jan 2007 04:35:21 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1H9eXG-0003n1-Vp
	for netdev@vger.kernel.org; Wed, 24 Jan 2007 10:35:18 +0100
Received: from 67.152.216.81.static.g-va.siw.siwnet.net ([81.216.152.67])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 24 Jan 2007 10:35:18 +0100
Received: from marcus by 67.152.216.81.static.g-va.siw.siwnet.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 24 Jan 2007 10:35:18 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The d80211 stack requires CRC32 functions for the WEP implementation.

Signed-off-by: Marcus Better <marcus@better.se>
---

 net/d80211/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index 7e2635f..d91f0db 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -3,6 +3,7 @@ config D80211
        select CRYPTO
        select CRYPTO_ARC4
        select CRYPTO_AES
+       select CRC32
        select WIRELESS_EXT
        ---help---
        This option enables the hardware independent IEEE 802.11
--


