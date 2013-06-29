From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/8] alx: fix 100mbit/half duplex speed translation
Date: Sat, 29 Jun 2013 19:23:14 +0200
Message-ID: <1372526600-15934-3-git-send-email-johannes@sipsolutions.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58300 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab3F2RXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:23:25 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Usyrs-0006aE-LL
	for netdev@vger.kernel.org; Sat, 29 Jun 2013 19:23:24 +0200
In-Reply-To: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

100mbit half duplex is ADVERTISED_100baseT_Half, not
ADVERTISED_10baseT_Half.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/alx/hw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index 220a16a..dc71cfb 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -1134,7 +1134,7 @@ static inline u32 alx_speed_to_ethadv(int speed)
 	case SPEED_100 + DUPLEX_FULL:
 		return ADVERTISED_100baseT_Full;
 	case SPEED_100 + DUPLEX_HALF:
-		return ADVERTISED_10baseT_Half;
+		return ADVERTISED_100baseT_Half;
 	case SPEED_10 + DUPLEX_FULL:
 		return ADVERTISED_10baseT_Full;
 	case SPEED_10 + DUPLEX_HALF:
-- 
1.8.0
