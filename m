From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: RE: re-submit2 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Wed, 31 Mar 2010 13:58:28 -0700
Message-ID: <1270069108.6053.5.camel@Linuxdev3>
References: <1269893596.9242.7.camel@Linuxdev3>
	 <20100330.230932.244208287.davem@davemloft.net>
	 <20100330.231051.113008279.davem@davemloft.net>
	 <8F90F944E50427428C60E12A34A309D22FC800D825@carmd-exchmb01.sierrawireless.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8F90F944E50427428C60E12A34A309D22FC800D825-3qf8vkpM5jTbmvMHnzRVpW3Pdy6AhKVLXbPIYa3/oNjDOqzlkpFKJg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-03-30 at 23:21 -0700, Rory Filer wrote:
> -----Original Message-----
> > >
> > > Applied, thanks.
> >=20
> > Nevermind, reverted, it doesn't even build.
> >=20
> > drivers/net/usb/sierra_net.c: In function 'check_ethip_packet':
> > drivers/net/usb/sierra_net.c:221:3: error: implicit declaration of
> > function 'deverr'
> >=20
> > Really, this should never ever happen, and there is simply
> > no excuse at all for this.
>=20
> Well actually there is an excuse, but I'm sure you don't want to
> know what it is.=20
=EF=BB=BF
The patch was posted saying it had only been tested on 2.6.33.1.=20
There was failure-to-build and boot problems  beyond our control with 2=
=2E6.34-rc2.
Now that 2.6.34-rc3 is available (and we are able to build and boot on =
our Ubuntu platform)
I will modify the driver to reflect the fact that deverr is no longer i=
n existence
and is replaced by another function. I will submit the modified driver =
tested on 2.6.34-rc3 shortly.
Perhaps we should have waited until the build problem was fixed.
Regards,
Elina

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
