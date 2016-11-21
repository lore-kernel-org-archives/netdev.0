From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [RFC PATCH net v2 2/3] dt: bindings: add ethernet phy
 eee-disable-advert option documentation
Date: Mon, 21 Nov 2016 17:47:33 +0100
Message-ID: <20161121164733.GG1922@lunn.ch>
References: <1479742524-30222-1-git-send-email-jbrunet@baylibre.com>
 <1479742524-30222-3-git-send-email-jbrunet@baylibre.com>
 <20161121160149.GF1922@lunn.ch>
 <1479744993.17538.85.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1479744993.17538.85.camel-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> What I did not realize when doing this patch for the realtek driver is
> that there is already 6 valid modes defined in the kernel
> 
> #define MDIO_EEE_100TX		MDIO_AN_EEE_ADV_100TX	/*
> 100TX EEE cap */
> #define MDIO_EEE_1000T		MDIO_AN_EEE_ADV_1000T	/*
> 1000T EEE cap */
> #define MDIO_EEE_10GT		0x0008	/* 10GT EEE cap */
> #define MDIO_EEE_1000KX		0x0010	/* 1000KX EEE cap
> */
> #define MDIO_EEE_10GKX4		0x0020	/* 10G KX4 EEE cap
> */
> #define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE cap
> */
> 
> I took care of only 2 in the case of realtek.c since it only support
> MDIO_EEE_100TX and MDIO_EEE_1000T.
> 
> Defining a property for each is certainly doable but it does not look
> very nice either. If it extends in the future, it will get even more
> messier, especially if you want to disable everything.

Yes, agreed.
 
> What do you think about keeping a single mask value but use the define
> above in the DT ? It would be more readable than hex and easy to
> extend, don't you think ?
> 
> These defines are already part of the uapi so I guess we can use those
> in the DT bindings ?

I don't think they are accessible from the dtc include path. You will
need to make a copy, in include/dt-bindings/net/phy.h

But yes, using these defines is a good idea.

     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
