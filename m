From: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 0/3] net: macb: rework at91 specific handling
Date: Thu,  5 Mar 2015 17:27:19 +0100
Message-ID: <1425572842-6084-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

This removes the #if defined(ARCH_AT91) sections to prevent any problem
when enabling ARM multi-platform support.
The at91 specific logic is now activated when the "at91sam9260-macb"
compatible string is found. 

Best Regards,

Boris

Boris Brezillon (3):
  net/macb: Update DT bindings documentation
  ARM: at91/dt: fix macb compatible strings
  net: macb: remove #if defined(CONFIG_ARCH_AT91) sections

 Documentation/devicetree/bindings/net/macb.txt |  5 +++-
 arch/arm/boot/dts/at91sam9260.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9263.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9g45.dtsi             |  2 +-
 arch/arm/boot/dts/at91sam9x5_macb0.dtsi        |  2 +-
 arch/arm/boot/dts/at91sam9x5_macb1.dtsi        |  2 +-
 arch/arm/boot/dts/sama5d3_emac.dtsi            |  2 +-
 drivers/net/ethernet/cadence/macb.c            | 33 ++++++++++++++------------
 drivers/net/ethernet/cadence/macb.h            |  2 ++
 9 files changed, 30 insertions(+), 22 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
