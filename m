From: Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 2/7] Documentation: devicetree: add PHY lane swap
 binding
Date: Tue, 1 Nov 2016 16:59:14 -0400
Message-ID: <20161101205913.GA27191@broadcom.com>
References: <1478030682-27012-1-git-send-email-jon.mason@broadcom.com>
 <1478030682-27012-3-git-send-email-jon.mason@broadcom.com>
 <20161101204826.GA21010@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161101204826.GA21010-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 09:48:26PM +0100, Andrew Lunn wrote:
> > +- enet-phy-lane-swap: If set, indicates the PHY device requires swapping the
> > +  TX/RX lanes to function properly.
> 
> Is 'requires' the right word here? The PHY performs the actual swap of
> the Tx/Rx lanes.

What I'm trying to say here is that without the lane swapping, the PHY
will not function properly.  Thus, those PHYs require this parameter
to work.  I am open to suggestions to reword the sentence to make it
clearer.

Thanks,
Jon

> 
>     Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
