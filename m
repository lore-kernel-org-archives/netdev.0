From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm4 4/4] r8169: Mac identifier extracted from Realtek's driver v2.2
Date: Fri, 10 Sep 2004 00:52:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909225247.GC10144@electric-eye.fr.zoreil.com>
References: <20040909224539.GA9629@electric-eye.fr.zoreil.com> <20040909224817.GA10144@electric-eye.fr.zoreil.com> <20040909224947.GB10144@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040909224947.GB10144@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Mac identifier extracted from Realtek's driver v2.2.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-170 drivers/net/r8169.c
--- linux-2.6.9-rc1/drivers/net/r8169.c~r8169-170	2004-09-08 22:55:42.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/r8169.c	2004-09-08 23:31:09.000000000 +0200
@@ -136,7 +136,8 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_B = 0x00,
 	/* RTL_GIGA_MAC_VER_C = 0x03, */
 	RTL_GIGA_MAC_VER_D = 0x01,
-	RTL_GIGA_MAC_VER_E = 0x02
+	RTL_GIGA_MAC_VER_E = 0x02,
+	RTL_GIGA_MAC_VER_X = 0x04	/* Greater than RTL_GIGA_MAC_VER_E */
 };
 
 enum phy_version {
@@ -869,6 +870,7 @@ static void rtl8169_get_mac_version(stru
 		u32 mask;
 		int mac_version;
 	} mac_info[] = {
+		{ 0x1 << 28,	RTL_GIGA_MAC_VER_X },
 		{ 0x1 << 26,	RTL_GIGA_MAC_VER_E },
 		{ 0x1 << 23,	RTL_GIGA_MAC_VER_D }, 
 		{ 0x00000000,	RTL_GIGA_MAC_VER_B } /* Catch-all */

_
