From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 09/21] r8169: prettify mac_version
Date: Fri, 29 Jun 2007 22:24:46 +0200
Message-ID: <20070629202446.GK3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46098 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754283AbXF2U2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:28:32 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

...still a bit yucky though.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 56b9040..eb793fa 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -151,11 +151,11 @@ static const int multicast_filter_limit = 32;
 #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
 
 enum mac_version {
-	RTL_GIGA_MAC_VER_01 = 0x00,
-	RTL_GIGA_MAC_VER_02 = 0x01,
-	RTL_GIGA_MAC_VER_03 = 0x02,
-	RTL_GIGA_MAC_VER_04 = 0x03,
-	RTL_GIGA_MAC_VER_05 = 0x04,
+	RTL_GIGA_MAC_VER_01 = 0x01, // 8169
+	RTL_GIGA_MAC_VER_02 = 0x02, // 8169S
+	RTL_GIGA_MAC_VER_03 = 0x03, // 8110S
+	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
+	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
 	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
 	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be 8168Bf
 	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb 8101Ec
@@ -180,11 +180,11 @@ static const struct {
 	u8 mac_version;
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880),
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880),
-	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880),
-	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880),
+	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880), // 8169
+	_R("RTL8169s",		RTL_GIGA_MAC_VER_02, 0xff7e1880), // 8169S
+	_R("RTL8110s",		RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
+	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
+	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, 0xff7e1880), // PCI-E
 	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, 0xff7e1880), // PCI-E
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, 0xff7e1880), // PCI-E 8139
-- 
1.4.4.2

