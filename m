From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Tue, 15 Jul 2008 13:58:31 -0400
Message-ID: <1216144711.13411.18.camel@localhost.localdomain>
References: <20080709190915.GA8238@tuxdriver.com>
	 <69e28c910807100912h30fcb57fpb4fb48b95c640f77@mail.gmail.com>
	 <200807101815.27204.mb@bu3sch.de>
	 <1216142191.6039.113.camel@localhost.localdomain>
	 <alpine.LFD.1.10.0807151323570.12484@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	Stefanik =?ISO-8859-1?Q?G=E1bor?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Nicolas Pitre <nico-mo2vmkxb4K0@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.1.10.0807151323570.12484-QuJgVwGFrdf/9pzu0YdTqQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-07-15 at 13:31 -0400, Nicolas Pitre wrote:
> On Tue, 15 Jul 2008, Dan Williams wrote:
>=20
> > On Thu, 2008-07-10 at 18:15 +0200, Michael Buesch wrote:
> > > On Thursday 10 July 2008 18:12:32 Stefanik G=C3=A1bor wrote:
> > > > Some other topics which might be of interest/good to include:
> > > > - New chipsets needing drivers (SiS 16x, Marvell, etc.)
> > >=20
> > > I have no idea what to discuss about non-existing drivers, really=
=2E
> > > Something like: "Do we need that driver? Everyone votes YES and i=
s happy"?
> >=20
> > Maybe during the week we could organize some hackfests to work on t=
he
> > Marvell/SiS/etc mac80211 drivers?  Everyone bring their favorite
> > non-working Marvell 88w83xx card and we make mrv8k our bitch or
> > something like that.
>=20
> FYI...
>=20
> Lennert Buytenhek and I are writing a GPL driver for mv8300 class of=20
> Marvell WIFI chips right now, present and future versions. This is=20
> Marvell work as we work for Marvell.  I have access to firmware sourc=
es,=20
> etc. but obviously cannot share them.
>=20
> We both will be in Ottawa next week.

Great!  Lets definitely sit down and talk then.  There is already some
GPL-ed source code for 83xx chips out there but it always used net80211=
,
not mac80211.  So the mrv8k effort is meant to write a mac80211 driver
for 8310/8335/etc and perhaps TopDog chips too since they don't seem
that much different from a driver perspective.

Some of the issues with the current Marvell 83xx GPL drivers that have
gotten out are (a) code style, (b) lots of commented out stuff that's
never used, (c) OS abstraction that's unnecessary on Linux, (d) doesn't
use mac80211, and (e) uses private ioctls.  So hopefully you're writing
a new 83xx driver from scratch :)

We cleaned up a lot of stuff for the OLPC 8388 libertas driver, but
unfortunately we never were able to get the Marvell 8388 team onboard,
and so they just went off and kept working on their driver and didn't
really move the upstream libertas driver forward at all.

Dan


--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
