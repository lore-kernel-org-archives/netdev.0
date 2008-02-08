From: akpm@linux-foundation.org
Subject: [patch 1/7] typhoon section fix
Date: Fri, 08 Feb 2008 03:11:13 -0800
Message-ID: <200802081120.m18BK6cL021623@imap1.linux-foundation.org>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	sam@ravnborg.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52301 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964883AbYBHLV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:21:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

gcc-3.4.4 on powerpc:

drivers/net/typhoon.c:137: error: version causes a section type conflict

Cc: Jeff Garzik <jeff@garzik.org>
Cc: Sam Ravnborg <sam@ravnborg.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/typhoon.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/typhoon.c~typhoon-section-fix drivers/net/typhoon.c
--- a/drivers/net/typhoon.c~typhoon-section-fix
+++ a/drivers/net/typhoon.c
@@ -134,7 +134,7 @@ static const int multicast_filter_limit 
 #include "typhoon.h"
 #include "typhoon-firmware.h"
 
-static const char version[] __devinitdata =
+static char version[] __devinitdata =
     "typhoon.c: version " DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
@@ -178,7 +178,7 @@ enum typhoon_cards {
 };
 
 /* directly indexed by enum typhoon_cards, above */
-static const struct typhoon_card_info typhoon_card_info[] __devinitdata = {
+static struct typhoon_card_info typhoon_card_info[] __devinitdata = {
 	{ "3Com Typhoon (3C990-TX)",
 		TYPHOON_CRYPTO_NONE},
 	{ "3Com Typhoon (3CR990-TX-95)",
_
