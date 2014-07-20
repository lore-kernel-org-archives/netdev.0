From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 30/30] ps3_gelic: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:30:48 +0200
Message-ID: <1405866648-24870-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index d568af1..1205472 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1831,25 +1831,18 @@ static const char *wpasecstr(enum gelic_eurus_wpa_security sec)
 	switch (sec) {
 	case GELIC_EURUS_WPA_SEC_NONE:
 		return "NONE";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA_TKIP_TKIP:
 		return "WPA_TKIP_TKIP";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA_TKIP_AES:
 		return "WPA_TKIP_AES";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA_AES_AES:
 		return "WPA_AES_AES";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA2_TKIP_TKIP:
 		return "WPA2_TKIP_TKIP";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA2_TKIP_AES:
 		return "WPA2_TKIP_AES";
-		break;
 	case GELIC_EURUS_WPA_SEC_WPA2_AES_AES:
 		return "WPA2_AES_AES";
-		break;
 	}
 	return "";
 };
-- 
1.9.1
