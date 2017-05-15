From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH 0/1] fix node name in the brcm,bcm43xx-fmac.txt example
Date: Mon, 15 May 2017 22:13:55 +0200
Message-ID: <20170515201356.26384-1-martin.blumenstingl@googlemail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

recently there were some negative comments about the quality of
code-reviews for new .dts additions. one issue that came up was that the
node for the Broadcom FullMAC wireless SDIO devices was named "brcmf"
instead of "wifi".

This patch tries to fix (one of) the root cause(s), which is that .dts
authors copy the example from the documentation.
unfortunately there are still many .dts files out there which use
"brmcf" as node name - so any new addition of a Broadcom FullMAC SDIO
wireless device should be reviewed carefully regarding the node name
(just in case a .dts author copied from another .dts which still uses
the "wrong" node name).

Martin Blumenstingl (1):
  dt-binding: net: wireless: fix node name in the BCM43xx example

 Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
