From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3 0/3] dp83640: Get pin and master/slave configuration
 from DT
Date: Thu, 13 Feb 2014 17:39:57 -0500 (EST)
Message-ID: <20140213.173957.2126489785330496380.davem@davemloft.net>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392302129-24947-1-git-send-email-stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Stefan S=F8rensen <stefan.sorensen-usnHOLptxrsHrNJx0XZkJA@public.gmane.org>
Date: Thu, 13 Feb 2014 15:35:22 +0100

> This patch series add DT configuration to the DP83640 PHY driver and =
makes
> the configuration of periodic output pins dynamic.
>=20
> Changes since v2:
>  - Add patch to properly configure perout triggers 0+1
>  - Keep extts and perout numbers separate
>  - Shorten pr_err lines
>=20
> Changes since v1:
>  - Add bindings documentation
>  - Keep module parameters
>  - Rename gpio->pin
>  - Split patch into DT part and dynamic periodic output support
>=20
> Stefan S=F8rensen (3):
>   net:phy:dp83640: Program pulsewidth2 values of perout triggers 0 an=
d 1
>   net:phy:dp83640: Support a configurable number of periodic outputs
>   net:phy:dp83640: Get pin and master/slave configuration from DT

I'm not applying this.

This is a great example of why I hate module parameters.

Whoever added these module parameters in the first place took the easy
road and didn't have to think about whether this was a good way or not
to specify these parameters.  Do you really think we can, like magic,
just remove this module parameter without having to think about the
consequences of that action at all?

The entities currently specifying this parameter, do they just lose?

Sorry, that's unacceptable.

You'll have to code this in a way such that people who currently specif=
y
this parameter keep working.

If you don't like it, be angry at whoever added this module parameter
in the first place, not me.  Module parameters are 99 times out of 100
not the right way to configure something, really.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
