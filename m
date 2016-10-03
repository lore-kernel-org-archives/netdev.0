From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] phy: micrel.c: Support ksz9031 energy-detect power-down
 mode
Date: Mon, 3 Oct 2016 16:35:08 +0200
Message-ID: <20161003143508.GA26382@lunn.ch>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1475499870-11465-1-git-send-email-mike.looijmans-Oq418RWZeHk@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +    Boolean:
> +
> +      - enable-edpd : Not related to timing. Specify this property to enable
> +                      energy-detect power-down mode in the PHY.

The Broadcom PHYs unconditionally enable this feature.

The SMSC driver has an option: smsc,disable-energy-detect because it
seems to have a rare hardware bug when it is enabled.

And you would like to make it off by default.

Could we avoid having three drivers doing three different things?
Could you have it unconditionally on, and see if anybody reports it
being broken?

      Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
