From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/8] wireless: airo: rename 'register' variable
Date: Thu, 16 Jun 2016 15:52:08 +0200
Message-ID: <20160616135245.3198419-1-arnd@arndb.de>
References: <20160616135020.3154461-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Kalle Valo <kvalo@codeaurora.org>,
	Ondrej Zary <linux@rainbow-software.org>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:54106 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbcFPNvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 09:51:15 -0400
In-Reply-To: <20160616135020.3154461-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'register' is a keyword in C and cannot be used in place of a
variable name, as shown by this -Wextra warning:

drivers/net/wireless/cisco/airo.c:1105:29: error: 'register' is not at beginning of declaration [-Werror=old-style-declaration]

This replaces the 'register' keyword with a 'reg' identifier in
the declaration, which matches the definition and has the intended
meaning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/cisco/airo.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/cisco/airo.c b/drivers/net/wireless/cisco/airo.c
index b6c9d5feef1f..6bdb6f6bdfe8 100644
--- a/drivers/net/wireless/cisco/airo.c
+++ b/drivers/net/wireless/cisco/airo.c
@@ -1102,8 +1102,8 @@ static const char version[] = "airo.c 0.6 (Ben Reed & Javier Achirica)";
 struct airo_info;
 
 static int get_dec_u16( char *buffer, int *start, int limit );
-static void OUT4500( struct airo_info *, u16 register, u16 value );
-static unsigned short IN4500( struct airo_info *, u16 register );
+static void OUT4500( struct airo_info *, u16 reg, u16 value );
+static unsigned short IN4500( struct airo_info *, u16 reg );
 static u16 setup_card(struct airo_info*, u8 *mac, int lock);
 static int enable_MAC(struct airo_info *ai, int lock);
 static void disable_MAC(struct airo_info *ai, int lock);
-- 
2.9.0
