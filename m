From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rt2x00: Fix crc-itu-t dependency
Date: Wed, 13 Dec 2006 18:07:13 +0100
Message-ID: <200612131807.13620.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:26800 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965007AbWLMRH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 12:07:26 -0500
Received: by nf-out-0910.google.com with SMTP id o25so573894nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 09:07:25 -0800 (PST)
To: "John Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crc-itu-t should only appear in the kernel configuration menu
when rt2x00 is enabled. The module should only be build when
rt2x00 is used, otherwise crc-itu-t is simply in the wrong
location since it is not a network driver.

Signed-off-by Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/drivers/net/wireless/d80211/rt2x00/Kconfig b/drivers/net/wireless/d80211/rt2x00/Kconfig
index c2c2a60..18d61c3 100644
--- a/drivers/net/wireless/d80211/rt2x00/Kconfig
+++ b/drivers/net/wireless/d80211/rt2x00/Kconfig
@@ -93,6 +93,7 @@ config EEPROM_93CX6
 
 config CRC_ITU_T
 	tristate "CRC ITU-T V.41 functions"
+	depends on RT2X00
 	help
 	  This option is provided for the case where no in-kernel-tree
 	  modules require CRC ITU-T V.41 functions, but a module built outside
