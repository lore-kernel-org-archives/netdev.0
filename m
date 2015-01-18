From: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/7] net: wireless: wcn36xx: add wcn3620 chip type definition
Date: Sun, 18 Jan 2015 13:10:43 +0800
Message-ID: <20150118051043.31866.53087.stgit@114-36-241-182.dynamic.hinet.net>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150118050741.31866.36490.stgit-FDDIDLfWL9/T9rR/E2HzMujRB4CPm7EUkgzjau31qRg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert the list of chip types to an enum, add the default
UNKNOWN type and a type for WCN3620 chip

Signed-off-by: Andy Green <andy.green-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index f0fb81d..a5366b6 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -93,6 +93,13 @@ struct nv_data {
 	u8	table;
 };
 
+enum wcn36xx_chip_type {
+	WCN36XX_CHIP_UNKNOWN,
+	WCN36XX_CHIP_3660,
+	WCN36XX_CHIP_3680,
+	WCN36XX_CHIP_3620,
+};
+
 /* Interface for platform control path
  *
  * @open: hook must be called when wcn36xx wants to open control channel.
@@ -179,7 +186,7 @@ struct wcn36xx {
 	u8			fw_minor;
 	u8			fw_major;
 	u32			fw_feat_caps[WCN36XX_HAL_CAPS_SIZE];
-	u32			chip_version;
+	enum wcn36xx_chip_type	chip_version;
 
 	/* extra byte for the NULL termination */
 	u8			crm_version[WCN36XX_HAL_VERSION_LENGTH + 1];
@@ -227,9 +234,6 @@ struct wcn36xx {
 
 };
 
-#define WCN36XX_CHIP_3660	0
-#define WCN36XX_CHIP_3680	1
