From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 2/5] net: rfkill: add rfkill_find_type function
Date: Thu, 06 Aug 2015 12:26:59 +0300
Message-ID: <1438853219.29746.184.camel@linux.intel.com>
References: <1438781947-7952-1-git-send-email-heikki.krogerus@linux.intel.com>
	 <1438781947-7952-3-git-send-email-heikki.krogerus@linux.intel.com>
	 <1438783649.29746.175.camel@linux.intel.com>
	 <20150806083004.GI7675@kuha.fi.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150806083004.GI7675-FZxXFokcWpatqXYlAKuG4QC/G2K4zDHf@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-06 at 11:30 +0300, Heikki Krogerus wrote:
> > >=20
> On Wed, Aug 05, 2015 at 05:07:29PM +0300, Andy Shevchenko wrote:
> > On Wed, 2015-08-05 at 16:39 +0300, Heikki Krogerus wrote:


> > > +static inline enum rfkill_type rfkill_find_type(const char
> > > *name)
> > > +{
> > > +	return 0;
> >=20
> > Hmm=E2=80=A6 Besides 0 is implicitly casted to enum type the issue =
with=20
> > enums
> > that you rather have to supply existing enum entry. I would suggest=
=20
> > to
> > add RFKILL_TYPE_UNKNOWN if _ALL is reserved for some use cases.
>=20
> Why would you add a new type just for this? You do realize it would
> require adding specific handling all over the place? RFKILL_TYPE_ALL
> (0) is already handled as an invalid type.

It was my thought as well (see *if* in my previous comment).

>  Confused?

A bit, yes.

>=20
> I'll change this and return RFKILL_TYPE_ALL instead of 0.

Excellent!

--=20
Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Intel Finland Oy
