From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: [PATCH] wlcore: spi: fix build warning caused by redundant variable
Date: Wed, 20 Jul 2016 07:30:20 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B36161A64@DFRE01.ent.ti.com>
References: <1468999637-31006-1-git-send-email-eyalr@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1468999637-31006-1-git-send-email-eyalr-l0cyMroinI0@public.gmane.org>
Content-Language: en-US
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ret variable is unused in wlcore_probe_of()
Remove it for fixing build warning.

Fixes: 01efe65aba65 ("wlcore: spi: add wl18xx support")
Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/spi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 73fbcf1..6d24040 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -454,7 +454,6 @@ static int wlcore_probe_of(struct spi_device *spi, struct wl12xx_spi_glue *glue,
 			   struct wlcore_platdev_data *pdev_data)
 {
 	struct device_node *dt_node = spi->dev.of_node;
-	int ret;
 	const struct of_device_id *of_id;
 
 	of_id = of_match_node(wlcore_spi_of_match_table, dt_node);
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
