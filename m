From: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH v5 1/3] net: Add mask for Control register 10Mbps speed
Date: Tue, 9 Aug 2016 15:04:41 +0530
Message-ID: <1470735283-23611-2-git-send-email-appanad@xilinx.com>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	<appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
	<punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470735283-23611-1-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds mask for the Control register
10Mbps speed.

Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
---
Changes for v5:
---> New patch as suggested by Punnaiah.

 include/uapi/linux/mii.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/mii.h b/include/uapi/linux/mii.h
index 237fac4..15d8510 100644
--- a/include/uapi/linux/mii.h
+++ b/include/uapi/linux/mii.h
@@ -48,6 +48,7 @@
 #define BMCR_SPEED100		0x2000	/* Select 100Mbps              */
 #define BMCR_LOOPBACK		0x4000	/* TXD loopback bits           */
 #define BMCR_RESET		0x8000	/* Reset to default state      */
+#define BMCR_SPEED10		0x0000	/* Select 10Mbps               */
 
 /* Basic mode status register. */
 #define BMSR_ERCAP		0x0001	/* Ext-reg capability          */
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
