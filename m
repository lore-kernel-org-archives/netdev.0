From: Greg KH <gregkh@suse.de>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of
 pseduo-platform busses
Date: Fri, 6 Aug 2010 16:46:35 -0700
Message-ID: <20100806234635.GC16793@suse.de>
References: <4C58A7AA.8020007@codeaurora.org>
 <20100803235631.GA17759@suse.de>
 <4C58AE15.6090900@codeaurora.org>
 <20100804000945.GA19729@suse.de>
 <4C58B1B6.9050005@quicinc.com>
 <AANLkTikVzh9=DvvUPbKmDeo6k2-pPVSnjH+GxAPdQFO4@mail.gmail.com>
 <20100806142727.GB4921@suse.de>
 <AANLkTi=VbVed09=u-Ea0L8c_CWZ_CLLjWH9ZjD2dyg6Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Pannuto <ppannuto@quicinc.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=VbVed09=u-Ea0L8c_CWZ_CLLjWH9ZjD2dyg6Y@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 06, 2010 at 09:12:27AM -0600, Grant Likely wrote:
> On Fri, Aug 6, 2010 at 8:27 AM, Greg KH <gregkh@suse.de> wrote:
> > On Thu, Aug 05, 2010 at 04:59:35PM -0600, Grant Likely wrote:
> >> (On that point Greg, what is the reason for even having the
> >> /sys/devices/platform/ parent? =A0Why not just let the platform de=
vices
> >> sit at the root of the device tree? =A0In the OF case (granted, I'=
m
> >> biased) all of the platform_device registrations reflect the actua=
l
> >> device hierarchy expressed in the device tree data.)
> >
> > If we sat them at the "root", there would be a bunch of them there.=
 =A0I
> > don't know, we could drop the parent, I guess whoever created the
> > platform device oh so long ago, decided that it would look nicer to=
 be
> > in this type of structure.
>=20
> Personally I'd rather see a meaningful structure used here.  Maybe
> having them all in the root will encourage people to find realistic
> parents for their platform devices.  :-)

That would be nice, but take your "standard" PC today:
	> ls /sys/devices/platform/
	Fixed MDIO bus.0  i8042  pcspkr  power  serial8250  uevent vesafb.0

There are tty devices below the serial port, which is nice to see, but
the others?  I don't know what type of bus they would be on, do you?

> Why don't I float a patch to remove this and see if anybody freaks
> out.  Should I wrap it with a CONFIG_ so that it can be configurable
> for a release or to, or just make it unconditional?

If you can figure out a structure for the desktop/server machines, sure=
,
I say just always enable it :)

thanks,

greg k-h
