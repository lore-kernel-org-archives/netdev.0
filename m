From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net: ethernet: mvneta: add support for 2.5G DRSGMII
 mode
Date: Wed, 25 Jan 2017 12:38:06 -0500 (EST)
Message-ID: <20170125.123806.790914338952471404.davem@davemloft.net>
References: <20170123142206.5390-1-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: jlu-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170123142206.5390-1-jlu-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Luebbe <jlu-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Date: Mon, 23 Jan 2017 15:22:06 +0100

> The Marvell MVNETA Ethernet controller supports a 2.5 Gbps SGMII mode
> called DRSGMII.
> 
> This patch adds a corresponding phy-mode string 'drsgmii' and parses it
> from DT. The MVNETA then configures the SERDES protocol value
> accordingly.
> 
> It was successfully tested on a MV78460 connected to a FPGA.
> 
> Signed-off-by: Jan Luebbe <jlu-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

I still haven't seen a sufficient explanation as to why this change
works without any explicit MAC programming changes to this driver.

That really needs to be explained before I will apply this patch.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
