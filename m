From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 09/15] via-rhine: mark some variables as __read_mostly.
Date: Mon, 31 Dec 2012 16:25:43 +0100
Message-ID: <1356967549-5056-10-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54123 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab2LaPeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:44 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index a4b8d84..ca788c0 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -49,14 +49,14 @@ static int debug = 0;
 #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) || \
 	defined(CONFIG_SPARC) || defined(__ia64__) ||		   \
 	defined(__sh__) || defined(__mips__)
-static int rx_copybreak = 1518;
+static int rx_copybreak __read_mostly = 1518;
 #else
-static int rx_copybreak;
+static int rx_copybreak __read_mostly;
 #endif
 
 /* Work-around for broken BIOSes: they are unable to get the chip back out of
    power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
-static bool avoid_D3;
+static bool avoid_D3 __read_mostly;
 
 /*
  * In case you are looking for 'options[]' or 'full_duplex[]', they
-- 
1.7.2.5
