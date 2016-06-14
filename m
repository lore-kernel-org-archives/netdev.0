From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCHv3 net-next 03/12] 6lowpan: remove ipv6 module request
Date: Tue, 14 Jun 2016 13:52:30 +0200
Message-ID: <20160614115239.17788-4-aar@pengutronix.de>
References: <20160614115239.17788-1-aar@pengutronix.de>
Cc: kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org,
	stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org, mcr-SWp7JaYWvAQV+D8aMU/kSg@public.gmane.org, werner-SEdMjqphH88wryQfseakQg@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160614115239.17788-1-aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since we use exported function from ipv6 kernel module we don't need to
request the module anymore to have ipv6 functionality.

Acked-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Signed-off-by: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
---
 net/6lowpan/core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
index 801404c..1c7a42b 100644
--- a/net/6lowpan/core.c
+++ b/net/6lowpan/core.c
@@ -158,8 +158,6 @@ static int __init lowpan_module_init(void)
 		return ret;
 	}
 
-	request_module_nowait("ipv6");
-
 	request_module_nowait("nhc_dest");
 	request_module_nowait("nhc_fragment");
 	request_module_nowait("nhc_hop");
-- 
2.8.3
