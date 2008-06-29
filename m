From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 13/13] r8169: change default behavior for mildly identified
	8168c chipsets
Date: Sun, 29 Jun 2008 16:49:17 +0200
Message-ID: <20080629144917.GN1540@electric-eye.fr.zoreil.com>
References: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, akpm@linux-foundation.org,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Mario Limonciello <mario_limonciello@dell.com>,
	Kasper Sandberg <lkml@metanurb.dk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46597 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760236AbYF2Oti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 10:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20080629143817.GA1540@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The addition of a new device has so far implied a specialization of
these masks. While they identify 8168c devices, they can be expected
to be further refined.

Realtek's 8168 driver has switched behavior for the devices. It should
bring the driver closer to the version 8.006.00 of Realtek's one.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 47fa19b..84e6fc4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1220,14 +1220,15 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		/* 8168B family. */
+		/* 8168C family. */
 		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
-		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_23 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
 		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
 		{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
-		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_22 },
 
 		/* 8168B family. */
 		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
-- 
1.5.3.3

