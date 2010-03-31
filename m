From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: RE: re-submit2 [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Thu, 01 Apr 2010 00:26:09 +0100
Message-ID: <1270077969.8653.491.camel@localhost>
References: <1269893596.9242.7.camel@Linuxdev3>
	 <20100330.230932.244208287.davem@davemloft.net>
	 <20100330.231051.113008279.davem@davemloft.net>
	 <8F90F944E50427428C60E12A34A309D22FC800D825@carmd-exchmb01.sierrawireless.local>
	 <1270069108.6053.5.camel@Linuxdev3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1270069108.6053.5.camel@Linuxdev3>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-03-31 at 13:58 -0700, Elina Pasheva wrote:
> On Tue, 2010-03-30 at 23:21 -0700, Rory Filer wrote:
> > -----Original Message-----
> > > >
> > > > Applied, thanks.
> > >=20
> > > Nevermind, reverted, it doesn't even build.
> > >=20
> > > drivers/net/usb/sierra_net.c: In function 'check_ethip_packet':
> > > drivers/net/usb/sierra_net.c:221:3: error: implicit declaration o=
f
> > > function 'deverr'
> > >=20
> > > Really, this should never ever happen, and there is simply
> > > no excuse at all for this.
> >=20
> > Well actually there is an excuse, but I'm sure you don't want to
> > know what it is.=20
> =EF=BB=BF
> The patch was posted saying it had only been tested on 2.6.33.1.
> There was failure-to-build and boot problems  beyond our control with=
 2.6.34-rc2.
> Now that 2.6.34-rc3 is available (and we are able to build and boot o=
n our Ubuntu platform)
> I will modify the driver to reflect the fact that deverr is no longer=
 in existence
> and is replaced by another function. I will submit the modified drive=
r tested on 2.6.34-rc3 shortly.

You should be sending patches based on David Miller's net-next-2.6 or
net-2.6 git repository, where he will be applying them.  As this is a
new driver I assume it can go into net-2.6.

> Perhaps we should have waited until the build problem was fixed.

Or come up with a fix yourself.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
