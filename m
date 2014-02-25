From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH] net: kdoc struct net_device flags and priv_flags
Date: Tue, 25 Feb 2014 07:09:51 +0100
Message-ID: <20140225060951.GA8299@wotan.suse.de>
References: <1393287245-4549-1-git-send-email-mcgrof@do-not-panic.com> <1393294265.6823.154.camel@deadeye.wl.decadent.org.uk> <20140224.235343.1936318499491821387.davem@davemloft.net> <2446186.I4KkJ8Hjdb@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@decadent.org.uk,
	mcgrof@do-not-panic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2446186.I4KkJ8Hjdb@lenovo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 24, 2014 at 09:37:34PM -0800, Florian Fainelli wrote:
> Le lundi 24 f=E9vrier 2014, 23:53:43 David Miller a =E9crit :
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Tue, 25 Feb 2014 02:11:05 +0000
> >=20
> > > On Mon, 2014-02-24 at 16:14 -0800, Luis R. Rodriguez wrote:
> > >> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> > >>=20
> > >> ---
> > >>=20
> > >>  include/uapi/linux/if.h | 201
> > >>  +++++++++++++++++++++++++++++++++++------------- 1 file changed=
, 149
> > >>  insertions(+), 52 deletions(-)
> > >>=20
> > >> diff --git a/include/uapi/linux/if.h b/include/uapi/linux/if.h
> > >> index d758163..1555623 100644
> > >> --- a/include/uapi/linux/if.h
> > >> +++ b/include/uapi/linux/if.h
> > >=20
> > > [...]
> > >=20
> > >> +/**
> > >> + * enum net_device_priv_flags - &struct net_device priv_flags
> > >> + *
> > >> + * These are the &struct net_device, they are only set internal=
ly
> > >> + * by drivers and used in the kernel but are invisible to users=
pace.
> > >=20
> > > [...]
> > >=20
> > > Indeed, I wonder why they are in the UAPI header.  As userland do=
esn't
> > > have a legitimate use for them, maybe you could move them back to
> > > include/linux/if.h instead of bothering with adding macros?
> >=20
> > They are visible to userspace via sysfs.
>=20
> In /sys/class/net/*/flags, although we are lacking quite a lot of doc=
umentation=20
> for the exported attributes there.
>=20
> The only attributes for which there is some sort of documentation are=
=20
> "operstate" and the XPS/RFS/RPS attributes, maybe that could be fixed=
 too as=20
> part of this documentation patch?

Sure, but how about we take it one step at a time? I wanted to do this =
first
so I can extend the documentation of some flags private flags I'm revie=
wing
right now, so figured we'd start with the basic, non contravertial simp=
le
documentation and then we can start piling up new shiny documentation.

  Luis
